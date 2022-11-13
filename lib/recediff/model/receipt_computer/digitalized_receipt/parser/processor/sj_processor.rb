# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class SJProcessor
              SJ = Record::SJ

              # @param values [Array<String, nil>] SJ行
              # @return [ShoujouShouki]
              def process(values)
                Receipt::ShoujouShouki.new(
                  category:    Receipt::ShoujouShouki::Category.find_by_code(values[SJ::C_症状詳記区分]),
                  description: values[SJ::C_症状詳記データ]
                )
              end
            end
          end
        end
      end
    end
  end
end
