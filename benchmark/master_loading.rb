# frozen_string_literal: true

require 'benchmark'
require 'logger'
require 'open3'
require 'pathname'
require_relative '../lib/receiptisan'

# rubocop:disable Metrics/ModuleLength
module MasterLoadingBenchmark
  VERSION = Receiptisan::Model::ReceiptComputer::Master::Version::V2024_R06
  MASTER = Receiptisan::Model::ReceiptComputer::Master
  LOADER_TYPES = %i[
    shinryou_koui
    iyakuhin
    tokutei_kizai
    comment
    shoubyoumei
    shuushokugo
  ].freeze

  class ForeachCollector
    Result = Struct.new(:loader, :io_and_encoding, :string_processing, :object_building, :lines, keyword_init: true)

    def initialize
      @results = Hash.new do | hash, key |
        hash[key] = Result.new(
          loader:            key,
          io_and_encoding:   0.0,
          string_processing: 0.0,
          object_building:   0.0,
          lines:             0
        )
      end
    end

    def record(loader_name, io_and_encoding:, string_processing:, object_building:, lines:)
      result = @results[loader_name]
      result.io_and_encoding += io_and_encoding
      result.string_processing += string_processing
      result.object_building += object_building
      result.lines += lines
    end

    def to_a
      @results.values.sort_by(&:loader)
    end
  end

  module ForeachProfiler
    class << self
      attr_accessor :collector
    end
  end

  module LoaderTraitInstrument
    def foreach(csv_paths)
      logger.info 'prepare to load following CSV %d files:' % csv_paths.length
      logger.info csv_paths.map(&:to_path)

      io_and_encoding = 0.0
      string_processing = 0.0
      object_building = 0.0
      lines = 0

      csv_paths.each do | csv_path |
        load_path, read_encoding = resolve_load_path(csv_path)
        contents = nil
        io_and_encoding += Benchmark.realtime do
          contents = File.read(load_path, mode: "r:#{read_encoding}:UTF-8")
        end

        rows = contents.split("\n")
        rows.each do | row |
          values = nil
          string_processing += Benchmark.realtime do
            values = row.delete_suffix("\r").tr('"', '').split(',')
          end
          object_building += Benchmark.realtime do
            yield values
          end
          lines += 1
        end

        logger.info "#{load_path}(#{rows.length} lines) was loaded."
      end

      ForeachProfiler.collector&.record(
        self.class.name.split('::').last,
        io_and_encoding:   io_and_encoding,
        string_processing: string_processing,
        object_building:   object_building,
        lines:             lines
      )
    end
  end

  module_function

  def run
    Receiptisan::Model::ReceiptComputer::Master::Loader::LoaderTrait.prepend(LoaderTraitInstrument)
    puts '=== Master CSV Loading Benchmark ==='
    puts "Version: #{VERSION}"
    puts

    benchmark_full_loading
    benchmark_by_loader_type
    benchmark_search_command
  end

  def benchmark_full_loading
    puts '[1] Full load benchmark (Loader#load)'
    times = []
    rss_diffs = []

    3.times do | i |
      before_rss = rss_kb
      elapsed = Benchmark.realtime { build_loader.load(VERSION) }
      after_rss = rss_kb
      times << elapsed
      rss_diffs << (after_rss - before_rss)
      puts format('  run%-2d: %.3fs (RSS %+d KB)', i + 1, elapsed, after_rss - before_rss)
    end

    puts format('  cold run: %.3fs', times.first)
    puts format('  warm avg: %.3fs', average(times.drop(1)))
    puts format('  RSS diff avg: %.1f KB', average(rss_diffs))
    puts
  end

  def benchmark_by_loader_type
    puts '[2][3] Breakdown by loader type and foreach phases'
    LOADER_TYPES.each do | type |
      elapsed_times = []
      collector = ForeachCollector.new

      3.times do | i |
        ForeachProfiler.collector = collector
        elapsed = Benchmark.realtime { build_loader.load_type(VERSION, type) }
        elapsed_times << elapsed
        puts format('  %-15s run%-2d: %.3fs', type, i + 1, elapsed)
      end

      puts format('  %-15s cold: %.3fs / warm avg: %.3fs', type, elapsed_times.first, average(elapsed_times.drop(1)))
      collector.to_a.each do | result |
        puts format(
          '    %-18s io+enc: %.3fs | split: %.3fs | build: %.3fs | lines: %d',
          result.loader,
          result.io_and_encoding,
          result.string_processing,
          result.object_building,
          result.lines
        )
      end
    ensure
      ForeachProfiler.collector = nil
    end
    puts
  end

  def benchmark_search_command
    puts '[4][5] receiptisan search end-to-end'
    cases = [
      ['max-shinryou', %w[--type shinryou-koui --name 初診 --month 202406]],
      ['mid-iyakuhin', %w[--type iyakuhin --name アセト --month 202406]],
      ['small-kizai', %w[--type tokutei-kizai --name カテーテル --month 202406]],
    ]

    cases.each do | name, args |
      times = []
      3.times do | i |
        elapsed = Benchmark.realtime do
          stdout, stderr, status = Open3.capture3(
            'bundle', 'exec', 'ruby', 'exe/receiptisan', 'search', *args,
            chdir: repo_root
          )
          next if status.success?

          raise "search failed (#{name}): #{stderr}\n#{stdout}"
        end
        times << elapsed
        puts format('  %-12s run%-2d: %.3fs', name, i + 1, elapsed)
      end

      puts format('  %-12s cold: %.3fs / warm avg: %.3fs', name, times.first, average(times.drop(1)))
    end
    puts
  end

  def build_loader
    MASTER::Loader.new(MASTER::ResourceResolver.new, Logger.new(nil))
  end

  def rss_kb
    line = File.read('/proc/self/status').each_line.find { | l | l.start_with?('VmRSS:') }
    return 0 unless line

    line.split[1].to_i
  end

  def average(values)
    return 0.0 if values.empty?

    values.sum(0.0) / values.length
  end

  def repo_root
    Pathname(__dir__).join('..').expand_path.to_path
  end
  # rubocop:enable Metrics/ModuleLength
end

MasterLoadingBenchmark.run if $PROGRAM_NAME == __FILE__
