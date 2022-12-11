# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class SJProcessor
              include Parser::Context::ErrorContextReportable

              SJ = Record::SJ

              # @param values [Array<String, nil>] SJ行
              # @return [ShoujouShouki]
              def process(values, context:)
                Receipt::ShoujouShouki.new(
                  category:    Receipt::ShoujouShouki::Category.find_by_code(values[SJ::C_症状詳記区分]),
                  description: values[SJ::C_症状詳記データ]
                )
              rescue StandardError => e
                report_error(e, context)
              end
            end
          end
        end
      end
    end
  end
end
