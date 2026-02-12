# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'receiptisan'
require 'logger'

RSpec::Core::RakeTask.new(:test)
RuboCop::RakeTask.new(:lint)

task default: :test

# rubocop:disable Metrics/BlockLength
namespace :master do
  desc 'マスターキャッシュを生成する（デフォルト: 最新2年度、VERSION=YYYY 指定可）'
  task :generate_cache do
    master = Receiptisan::Model::ReceiptComputer::Master
    logger = Logger.new($stderr, level: Logger::INFO)
    loader = master::Loader.new(master::ResourceResolver.new, logger)

    versions = master::Version.values.sort_by(&:year)
    version_env = ENV.fetch('VERSION', nil)
    target_versions = if version_env
                        year = Integer(version_env, 10)
                        versions.select { | version | version.year == year }
                      else
                        versions.last(2)
                      end

    abort "No master version matched VERSION=#{version_env.inspect}" if target_versions.empty?

    target_versions.each do | version |
      loader.generate_cache(version)
      puts "generated cache for master version #{version.year}"
    end
  end

  desc '利用可能なマスターバージョン一覧を表示する'
  task :list_versions do
    master = Receiptisan::Model::ReceiptComputer::Master
    versions = master::Version.values.sort_by(&:year)
    versions.each do | version |
      puts "#{version.year}: #{version.term.begin}～#{version.term.end}"
    end
  end
end
# rubocop:enable Metrics/BlockLength
