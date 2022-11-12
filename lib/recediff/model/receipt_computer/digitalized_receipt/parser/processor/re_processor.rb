# frozen_string_literal: true

require 'month'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class REProcessor
              RE          = Record::RE
              DateParser  = Recediff::Util::DateParser
              ReceiptType = DigitalizedReceipt::Receipt::Type
              Patient     = DigitalizedReceipt::Receipt::Patient

              # @param values [Array<String, nil>]
              # @param audit_payer [DigitalizedReceipt::AuditPayer, nil]
              # @return [Receipt]
              def process(values)
                raise StandardError, 'line isnt RE record' unless values.first == 'RE'

                process_new_receipt(values).tap { | receipt | process_tokki_jikous(receipt, values) }
              end

              private

              # @param values [Array<String, nil>]
              # @return [Receipt]
              def process_new_receipt(values)
                Receipt.new(
                  id:          values[RE::C_レセプト番号].to_i,
                  shinryou_ym: DateParser.parse_year_month(values[RE::C_診療年月]),
                  type:        ReceiptType.of(values[RE::C_レセプト種別]),
                  patient:     Patient.new(
                    id:         values[RE::C_カルテ番号等],
                    name:       values[RE::C_氏名],
                    name_kana:  values[RE::C_カタカナ氏名],
                    sex:        Sex.find_by_code(values[RE::C_男女区分]),
                    birth_date: Date.parse(values[RE::C_生年月日])
                  )
                )
              end

              # @param receipt [Receipt]
              # @param values [Array<String, nil>]
              # @return [void]
              def process_tokki_jikous(receipt, values)
                values[RE::C_レセプト特記事項].to_s.scan(/\d\d/).each do | code |
                  receipt.add_tokki_jikou(Receipt::TokkiJikou.find_by_code(code))
                end
              end
            end
          end
        end
      end
    end
  end
end
