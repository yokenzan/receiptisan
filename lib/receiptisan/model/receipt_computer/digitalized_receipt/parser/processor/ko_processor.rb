# frozen_string_literal: true

require 'month'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class KOProcessor
              KO = Record::KO

              # @param is_nyuuin [Boolean]
              # @param values [Array<String, nil>]
              # @return [IryouHoken]
              def process(is_nyuuin, values)
                raise StandardError, 'line isnt KO record' unless values.first == 'KO'

                DigitalizedReceipt::Receipt::KouhiFutanIryou.new(
                  futansha_bangou:  values[KO::C_公費負担者番号],
                  jukyuusha_bangou: values[KO::C_公費受給者番号],
                  nissuu_kyuufu:    DigitalizedReceipt::Receipt::NissuuKyuufu.new(
                    goukei_tensuu:                           values[KO::C_合計点数].to_i,
                    shinryou_jitsunissuu:                    values[KO::C_診療実日数].to_i,
                    ichibu_futankin:                         values[KO::C_負担金額_公費].to_i,
                    kyuufu_taishou_ichibu_futankin:          (is_nyuuin ?
                      values[KO::C_公費給付対象入院一部負担金] :
                      values[KO::C_公費給付対象外来一部負担金])&.to_i,
                    shokuji_seikatsu_ryouyou_kaisuu:         values[KO::C_食事療養・生活療養_回数].to_i,
                    shokuji_seikatsu_ryouyou_goukei_kingaku: values[KO::C_食事療養・生活療養_合計金額].to_i
                  )
                )
              end
            end
          end
        end
      end
    end
  end
end
