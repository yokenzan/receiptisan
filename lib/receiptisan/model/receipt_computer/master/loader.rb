# frozen_string_literal: true

require_relative 'cache_policy'
require_relative 'cache_store'
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
          MASTER_TYPES = %i[
            shinryou_koui
            iyakuhin
            tokutei_kizai
            comment
            shoubyoumei
            shuushokugo
          ].freeze

          # @param resource_resolver [ResourceResolver]
          # @param logger [Logger]
          # @param cache_store [CacheStore, nil]
          # @param cache_policy [CachePolicy, nil]
          def initialize(resource_resolver, logger, cache_store: nil, cache_policy: nil)
            @resource_resolver    = resource_resolver
            @shinryou_koui_loader = ShinryouKouiLoader.new(logger)
            @iyakuhin_loader      = IyakuhinLoader.new(logger)
            @tokutei_kizai_loader = TokuteiKizaiLoader.new(logger)
            @comment_loader       = CommentLoader.new(logger)
            @shoubyoumei_loader   = ShoubyoumeiLoader.new(logger)
            @shuushokugo_loader   = ShuushokugoLoader.new(logger)
            @cache_store          = cache_store || CacheStore.new(logger)
            @cache_policy         = cache_policy || CachePolicy.new
            @logger               = logger
          end

          # @param version [Version]
          # @return [Master]
          def load(version)
            logger.info("preparing to load master version #{version.year}")

            csv_paths = @resource_resolver.detect_csv_files(version)
            cache_path = @cache_store.detect_cache_path(csv_paths)
            cache = @cache_store.read(cache_path, csv_paths)
            return cache if cache

            warn_cache_not_found(cache_path)
            load_from_version_and_csv(version, **csv_paths).tap do | loaded |
              @cache_store.write(cache_path, loaded) if @cache_policy.write_on_cache_miss?
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
            cache_path = @cache_store.detect_type_cache_path(csv_paths, type)
            cache = @cache_store.read(cache_path, csv_paths)
            return cache if cache

            warn_cache_not_found(cache_path)
            load_type_from_csv_paths(version, type, csv_paths).tap do | loaded |
              @cache_store.write(cache_path, loaded) if @cache_policy.write_on_cache_miss?
            end
          end

          # キャッシュを事前生成する
          #
          # @param version [Version]
          # @return [void]
          def generate_cache(version)
            logger.info("generating master cache version #{version.year}")

            csv_paths = @resource_resolver.detect_csv_files(version)
            master = load_from_version_and_csv(version, **csv_paths)
            @cache_store.write(@cache_store.detect_cache_path(csv_paths), master)

            MASTER_TYPES.each do | type |
              @cache_store.write(
                @cache_store.detect_type_cache_path(csv_paths, type),
                load_type_from_csv_paths(version, type, csv_paths)
              )
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

          # @param cache_path [Pathname]
          # @return [void]
          def warn_cache_not_found(cache_path)
            return unless @cache_policy.warn_on_cache_miss?
            return unless @cache_store.cache_missing?(cache_path)

            logger.warn("master cache not found: #{cache_path}")
            logger.warn("to generate cache, run: #{@cache_policy.generate_cache_command}")
          end

          attr_reader :logger
        end
      end
    end
  end
end
