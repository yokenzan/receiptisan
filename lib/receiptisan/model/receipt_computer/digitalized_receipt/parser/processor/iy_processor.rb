# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class IYProcessor
              include Context::ErrorContextReportable

              IY             = DigitalizedReceipt::Record::IY
              Iyakuhin       = Receipt::Tekiyou::Resource::Iyakuhin
              MasterIyakuhin = Master::Treatment::Iyakuhin

              # @param handler [MasterHandler]
              def initialize(logger:, context:, handler:)
                @handler = handler
                @logger  = logger
                @context = context
              end

              # @param values [Array<String, nil>] IY行
              # @return [Receipt::Tekiyou::Resource::Iyakuhin]
              def process(values)
                raise StandardError, 'line isnt IY record' unless values.first == 'IY'

                Iyakuhin.new(
                  master_item: handler.find_by_code(code = MasterIyakuhin::Code.of(values[IY::C_レセ電コード])),
                  shiyouryou:  shiyouryou = values[Record::IY::C_使用量]&.to_f
                )
              rescue Master::MasterItemNotFoundError => e
                report_error(e)

                Iyakuhin.dummy(code: code, shiyouryou: shiyouryou)
              rescue StandardError => e
                report_error(e)
              end

              private

              attr_reader :handler, :logger, :context
            end
          end
        end
      end
    end
  end
end
