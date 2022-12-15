# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class SIProcessor
              include Context::ErrorContextReportable

              SI                 = DigitalizedReceipt::Record::SI
              ShinryouKoui       = Receipt::Tekiyou::Resource::ShinryouKoui
              MasterShinryouKoui = Master::Treatment::ShinryouKoui

              # @param handler [MasterHandler]
              def initialize(logger:, context:, handler:)
                @handler = handler
                @logger  = logger
                @context = context
              end

              # @param values [Array<String, nil>] SI行
              # @return [Receipt::Tekiyou::Resource::ShinryouKoui]
              def process(values)
                raise StandardError, 'line isnt SI record' unless values.first == 'SI'

                ShinryouKoui.new(
                  master_item: handler.find_by_code(code = MasterShinryouKoui::Code.of(values[SI::C_レセ電コード])),
                  shiyouryou:  shiyouryou = values[SI::C_数量データ]&.to_i
                )
              rescue Master::MasterItemNotFoundError => e
                report_error(e)

                ShinryouKoui.dummy(code: code, shiyouryou: shiyouryou)
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
