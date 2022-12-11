# frozen_string_literal: true

require 'month'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class HOProcessor
              include Context::ErrorContextReportable

              HO = Record::HO

              # @param values [Array<String, nil>] HO行
              # @return [IryouHoken]
              def process(values, kyuufu_wariai, teishotoku_kubun, context:)
                raise StandardError, 'line isnt HO record' unless values.first == 'HO'

                begin
                  DigitalizedReceipt::Receipt::IryouHoken.new(
                    hokenja_bangou:   values[HO::C_保険者番号],
                    kigou:            values[HO::C_被保険者証等の記号],
                    bangou:           values[HO::C_被保険者証等の番号],
                    kyuufu_wariai:    kyuufu_wariai,
                    teishotoku_kubun: teishotoku_kubun,
                    gemmen_kubun:     values[HO::C_負担金額_減免区分],
                    nissuu_kyuufu:    DigitalizedReceipt::Receipt::NissuuKyuufu.new(
                      goukei_tensuu:                           values[HO::C_合計点数]&.to_i,
                      shinryou_jitsunissuu:                    values[HO::C_診療実日数]&.to_i,
                      ichibu_futankin:                         values[HO::C_負担金額_医療保険]&.to_i,
                      kyuufu_taishou_ichibu_futankin:          nil,
                      shokuji_seikatsu_ryouyou_kaisuu:         values[HO::C_食事療養・生活療養_回数]&.to_i,
                      shokuji_seikatsu_ryouyou_goukei_kingaku: values[HO::C_食事療養・生活療養_合計金額]&.to_i
                    )
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
end
