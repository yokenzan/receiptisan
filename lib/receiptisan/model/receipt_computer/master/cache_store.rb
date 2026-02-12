# frozen_string_literal: true

require 'fileutils'
require 'pathname'

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class CacheStore
          # @param logger [Logger]
          def initialize(logger)
            @logger = logger
          end

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
          # @return [Object, nil]
          def read(cache_path, csv_paths)
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
          # @param data [Object]
          # @return [void]
          def write(cache_path, data)
            FileUtils.mkdir_p(cache_path.dirname)
            cache_path.binwrite(Marshal.dump(data))
          rescue StandardError => e
            logger.warn("failed to write cache(#{cache_path}): #{e.class}: #{e.message}")
          end

          # @param cache_path [Pathname]
          # @return [Boolean]
          def cache_missing?(cache_path)
            !cache_path.exist?
          end

          private

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
