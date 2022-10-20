# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Shoubyoumei
          WORPRO_SOUBYOUMEI_CODE = '0000999'

          def initialize(
            master_shoubyoumei:,
            name:,
            is_main:,
            start_date:,
            tenki:,
            additional_comment:
          )
            @master_shoubyoumei  = master_shoubyoumei
            @name                = name
            @is_main             = is_main
            @start_date          = start_date
            @tenki               = tenki
            @additional_comment  = additional_comment
            @master_shuushokugos = []
          end

          # @param [ReceiptComputer::Master::Diagnose::Shuushokugo] shuushokugo
          # @return [void]
          def add_shuushokugo(shuushokugo)
            @master_shuushokugos << shuushokugo
          end

          attr_reader :master_shoubyoumei
          attr_reader :master_shuushokugos
          attr_reader :name
          attr_reader :is_main
          attr_reader :start_date
          attr_reader :tenki
          attr_reader :additional_comment

          # 転帰
          class Tenki
            def initialize(code:, name:)
              @code = code
              @name = name
            end

            # @!attribute [r] code
            #   @return [String]
            # @!attribute [r] name
            #   @return [String]
            attr_reader :code, :name

            @types = {
              '1': new(code: 1, name: '継続'), # 治ゆ、死亡、中止以外
              '2': new(code: 2, name: '治癒'),
              '3': new(code: 3, name: '死亡'),
              '4': new(code: 4, name: '中止'),
            }
            @types.each(&:freeze).freeze

            class << self
              # @param code [String, Integer]
              # @return [self, nil]
              def find_by_code(code)
                @types[code.to_s.intern]
              end
            end
          end
        end
      end
    end
  end
end
