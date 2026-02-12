# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class CachePolicy
          DEFAULT_GENERATE_CACHE_COMMAND = 'rake master:generate_cache'

          # @param write_on_cache_miss [Boolean]
          # @param warn_on_cache_miss [Boolean]
          # @param generate_cache_command [String]
          def initialize(
            write_on_cache_miss: false,
            warn_on_cache_miss: true,
            generate_cache_command: DEFAULT_GENERATE_CACHE_COMMAND
          )
            @write_on_cache_miss    = write_on_cache_miss
            @warn_on_cache_miss     = warn_on_cache_miss
            @generate_cache_command = generate_cache_command
          end

          # @return [Boolean]
          def write_on_cache_miss?
            @write_on_cache_miss
          end

          # @return [Boolean]
          def warn_on_cache_miss?
            @warn_on_cache_miss
          end

          # @return [String]
          attr_reader :generate_cache_command
        end
      end
    end
  end
end
