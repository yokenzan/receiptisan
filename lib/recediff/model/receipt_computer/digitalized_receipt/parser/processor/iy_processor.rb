# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class IYProcessor
              IY = DigitalizedReceipt::Record::IY

              # @param handler [MasterHandler]
              def initialize(handler)
                @handler = handler
              end

              # @param values [Array<String, nil>] IY行
              # @return [Receipt::ShinryouKoui]
              def process(values)
                raise StandardError, 'line isnt IY record' unless values.first == 'IY'

                Receipt::Iyakuhin.new(
                  master_iyakuhin: handler.find_by_code(Master::IyakuhinCode.of(values[IY::C_レセ電コード])),
                  shiyouryou:      values[Record::IY::C_使用量]&.to_f
                )
              end

              private

              attr_reader :handler
            end
          end
        end
      end
    end
  end
end
