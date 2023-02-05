# frozen_string_literal: true

require 'month'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class IRProcessor
              IR       = Record::IR
              DateUtil = Receiptisan::Util::DateUtil

              # @param values [Array<String, nil>] IR行
              # @param hospital_location [String, nil] 医療機関所在地
              # @param hospital_bed_count [Integer] 医療機関病床数
              # @return [DigitalizedReceipt]
              def process(values, hospital_location, hospital_bed_count)
                raise StandardError, 'line isnt IR record' unless values.first == 'IR'

                hospital = Hospital.new(
                  code:       values[IR::C_医療機関コード],
                  name:       values[IR::C_医療機関名称],
                  tel:        values[IR::C_電話番号],
                  prefecture: Prefecture.find_by_code(values[IR::C_都道府県].to_i),
                  location:   hospital_location,
                  bed_count:  hospital_bed_count
                )
                DigitalizedReceipt.new(
                  seikyuu_ym:  DateUtil.parse_year_month(values[IR::C_請求年月]),
                  audit_payer: AuditPayer.find_by_code(values[IR::C_審査支払機関].to_i),
                  hospital:    hospital
                )
              end

              def hospital_code(values)
                raise StandardError, 'line isnt IR record' unless values.first == 'IR'

                values[IR::C_医療機関コード]
              end
            end
          end
        end
      end
    end
  end
end
