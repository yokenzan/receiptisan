# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class IYProcessor
              IY             = DigitalizedReceipt::Record::IY
              Iyakuhin       = Receipt::Tekiyou::Cost::Iyakuhin
              MasterIyakuhin = Master::Treatment::Iyakuhin

              # @param handler [MasterHandler]
              def initialize(handler)
                @handler = handler
              end

              # @param values [Array<String, nil>] IY行
              # @return [Receipt::Tekiyou::Cost::Iyakuhin]
              def process(values)
                raise StandardError, 'line isnt IY record' unless values.first == 'IY'

                Iyakuhin.new(
                  master_iyakuhin: handler.find_by_code(MasterIyakuhin::Code.of(values[IY::C_レセ電コード])),
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
