# frozen_string_literal: true

require 'month'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class REProcessor
              RE          = Record::RE
              DateUtil    = Receiptisan::Util::DateUtil
              ReceiptType = DigitalizedReceipt::Receipt::Type
              Patient     = DigitalizedReceipt::Receipt::Patient

              def initialize
                @receipt_type_builder = Parser::ReceiptTypeBuilder.new
                @kyuufu_wariai        = nil
                @teishotoku_kubun     = nil
              end

              # @param values [Array<String, nil>]
              # @param audit_payer [DigitalizedReceipt::AuditPayer, nil]
              # @return [Receipt]
              def process(values, audit_payer)
                raise StandardError, 'line isnt RE record' unless values.first == 'RE'

                @kyuufu_wariai   = nil
                @teishotoku_type = nil

                process_new_receipt(values, audit_payer).tap do | receipt |
                  process_tokki_jikous(receipt, values)
                  process_byoushou_types(receipt, values)
                end
              end

              def kyuufu_wariai
                @kyuufu_wariai.tap { @kyuufu_wariai = nil }
              end

              def teishotoku_type
                @teishotoku_type.tap { @teishotoku_type = nil }
              end

              private

              # @param values [Array<String, nil>]
              # @param audit_payer [DigitalizedReceipt::AuditPayer, nil]
              # @return [Receipt]
              def process_new_receipt(values, audit_payer)
                @receipt_type_builder.audit_payer = audit_payer

                type             = @receipt_type_builder.build_with(values[RE::C_レセプト種別])
                @kyuufu_wariai   = values[RE::C_給付割合]&.to_i
                @teishotoku_type = Receipt::TeishotokuType.find_by_code(
                  values[RE::C_一部負担金・食事療養費・生活療養費標準負担額区分]
                )

                Receipt.new(
                  id:          values[RE::C_レセプト番号].to_i,
                  shinryou_ym: DateUtil.parse_year_month(values[RE::C_診療年月]),
                  type:        type,
                  nyuuin_date: type.nyuuin? ? Date.parse(values[RE::C_入院年月日]) : nil,
                  patient:     Patient.new(
                    id:         values[RE::C_カルテ番号等],
                    name:       values[RE::C_氏名],
                    name_kana:  values[RE::C_カタカナ氏名],
                    sex:        Sex.find_by_code(values[RE::C_男女区分]),
                    birth_date: Date.parse(values[RE::C_生年月日])
                  ),
                  audit_payer: audit_payer
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

              # @param receipt [Receipt]
              # @param values [Array<String, nil>]
              # @return [void]
              def process_byoushou_types(receipt, values)
                values[RE::C_病棟区分].to_s.scan(/\d\d/).each do | code |
                  receipt.add_byoushou_type(DigitalizedReceipt::ByoushouType.find_by_code(code))
                end
              end
            end
          end
        end
      end
    end
  end
end
