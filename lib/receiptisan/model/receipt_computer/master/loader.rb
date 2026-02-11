# frozen_string_literal: true

require 'fileutils'
require 'pathname'

require_relative 'loader/loader_trait'
require_relative 'loader/shinryou_koui_loader'
require_relative 'loader/iyakuhin_loader'
require_relative 'loader/tokutei_kizai_loader'
require_relative 'loader/comment_loader'
require_relative 'loader/shoubyoumei_loader'
require_relative 'loader/shuushokugo_loader'

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class Loader
          # @param resource_resolver [ResourceResolver]
          def initialize(resource_resolver, logger)
            @resource_resolver    = resource_resolver
            @shinryou_koui_loader = ShinryouKouiLoader.new(logger)
            @iyakuhin_loader      = IyakuhinLoader.new(logger)
            @tokutei_kizai_loader = TokuteiKizaiLoader.new(logger)
            @comment_loader       = CommentLoader.new(logger)
            @shoubyoumei_loader   = ShoubyoumeiLoader.new(logger)
            @shuushokugo_loader   = ShuushokugoLoader.new(logger)
            @logger               = logger
          end

          # @param version [Version]
          # @return [Master]
          def load(version)
            logger.info("preparing to load master version #{version.year}")

            csv_paths = @resource_resolver.detect_csv_files(version)
            cache_path = detect_cache_path(csv_paths)
            cache = load_from_cache(cache_path, csv_paths)
            return cache if cache

            load_from_version_and_csv(version, **csv_paths).tap do | master |
              write_cache(cache_path, master)
              logger.info("loading master version #{version.year} completed")
            end
          end

          # @param version [Version]
          # @param shinryou_koui_csv_path [String]
          # @param iyakuhin_csv_path [String]
          # @param tokutei_kizai_csv_path [String]
          # @param comment_csv_path [String]
          # @param shoubyoumei_csv_path [String]
          # @param shuushokugo_csv_path [String]
          # @return [Master]
          def load_from_version_and_csv(
            version,
            shinryou_koui_csv_path:,
            iyakuhin_csv_path:,
            tokutei_kizai_csv_path:,
            comment_csv_path:,
            shoubyoumei_csv_path:,
            shuushokugo_csv_path:
          )
            Master.new(
              shinryou_koui: @shinryou_koui_loader.load(version, shinryou_koui_csv_path),
              iyakuhin:      @iyakuhin_loader.load(iyakuhin_csv_path),
              tokutei_kizai: @tokutei_kizai_loader.load(tokutei_kizai_csv_path),
              comment:       @comment_loader.load(comment_csv_path),
              shoubyoumei:   @shoubyoumei_loader.load(shoubyoumei_csv_path),
              shuushokugo:   @shuushokugo_loader.load(shuushokugo_csv_path)
            )
          end

          # 指定された1種別のCSVだけをロードし、その種別のHashを返す
          #
          # @param version [Version]
          # @param type [Symbol] :shinryou_koui, :iyakuhin, :tokutei_kizai, :comment, :shoubyoumei, :shuushokugo
          # @return [Hash]
          def load_type(version, type)
            csv_paths = @resource_resolver.detect_csv_files(version)
            cache_path = detect_type_cache_path(csv_paths, type)
            cache = load_from_cache(cache_path, csv_paths)
            return cache if cache

            load_type_from_csv_paths(version, type, csv_paths).tap do | loaded |
              write_cache(cache_path, loaded)
            end
          end

          # @param version [Version]
          # @param type [Symbol]
          # @param csv_paths [Hash<Symbol, Array<Pathname>>]
          # @return [Hash]
          def load_type_from_csv_paths(version, type, csv_paths)
            case type
            when :shinryou_koui
              @shinryou_koui_loader.load(version, csv_paths[:shinryou_koui_csv_path])
            when :iyakuhin
              @iyakuhin_loader.load(csv_paths[:iyakuhin_csv_path])
            when :tokutei_kizai
              @tokutei_kizai_loader.load(csv_paths[:tokutei_kizai_csv_path])
            when :comment
              @comment_loader.load(csv_paths[:comment_csv_path])
            when :shoubyoumei
              @shoubyoumei_loader.load(csv_paths[:shoubyoumei_csv_path])
            when :shuushokugo
              @shuushokugo_loader.load(csv_paths[:shuushokugo_csv_path])
            else
              raise ArgumentError, "unknown master type: #{type}"
            end
          end

          private

          # @param csv_paths [Hash<Symbol, Array<Pathname>>]
          # @return [Pathname]
          def detect_cache_path(csv_paths)
            sample_path = csv_paths.values.flatten.first
            sample_path.parent.join('.cache', 'master.marshal')
          end

          # @param csv_paths [Hash<Symbol, Array<Pathname>>]
          # @param type [Symbol]
          # @return [Pathname]
          def detect_type_cache_path(csv_paths, type)
            sample_path = csv_paths.values.flatten.first
            sample_path.parent.join('.cache', "#{type}.marshal")
          end

          # @param cache_path [Pathname]
          # @param csv_paths [Hash<Symbol, Array<Pathname>>]
          # @return [Master, nil]
          def load_from_cache(cache_path, csv_paths)
            return nil unless cache_available?(cache_path, csv_paths)

            logger.info("loading master cache: #{cache_path}")
            # rubocop:disable Security/MarshalLoad
            Marshal.load(cache_path.binread)
            # rubocop:enable Security/MarshalLoad
          rescue StandardError => e
            logger.warn("failed to load cache(#{cache_path}): #{e.class}: #{e.message}")
            nil
          end

          # @param cache_path [Pathname]
          # @param master [Master]
          # @return [void]
          def write_cache(cache_path, master)
            FileUtils.mkdir_p(cache_path.dirname)
            cache_path.binwrite(Marshal.dump(master))
          rescue StandardError => e
            logger.warn("failed to write cache(#{cache_path}): #{e.class}: #{e.message}")
          end

          # @param cache_path [Pathname]
          # @param csv_paths [Hash<Symbol, Array<Pathname>>]
          # @return [Boolean]
          def cache_available?(cache_path, csv_paths)
            return false unless cache_path.exist?

            cache_mtime = cache_path.mtime
            target_dir = csv_paths.values.flatten.first.parent
            latest_mtime = target_source_paths(target_dir).map(&:mtime).max
            return true unless latest_mtime

            cache_mtime >= latest_mtime
          end

          # @param target_dir [Pathname]
          # @return [Array<Pathname>]
          def target_source_paths(target_dir)
            pattern = target_dir.join('**', '*.{csv,txt,CSV,TXT}').to_path
            Dir.glob(pattern).map { | path | Pathname(path) }
          end

          attr_reader :logger
        end
      end
    end
  end
end
