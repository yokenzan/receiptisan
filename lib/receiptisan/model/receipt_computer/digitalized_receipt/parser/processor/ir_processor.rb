# frozen_string_literal: true

require 'month'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class IRProcessor
              include Context::ErrorContextReportable

              IR       = Record::IR
              DateUtil = Receiptisan::Util::DateUtil

              # @param values [Array<String, nil>] IR行
              # @return [DigitalizedReceipt]
              def process(values, context:)
                raise StandardError, 'line isnt IR record' unless values.first == 'IR'

                hospital = Hospital.new(
                  code:       values[IR::C_医療機関コード],
                  name:       values[IR::C_医療機関名称],
                  tel:        values[IR::C_電話番号],
                  prefecture: Prefecture.find_by_code(values[IR::C_都道府県].to_i)
                )
                DigitalizedReceipt.new(
                  seikyuu_ym:  DateUtil.parse_year_month(values[IR::C_請求年月]),
                  audit_payer: AuditPayer.find_by_code(values[IR::C_審査支払機関].to_i),
                  hospital:    hospital
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
