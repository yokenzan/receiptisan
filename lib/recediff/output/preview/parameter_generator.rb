# frozen_string_literal: true

module Recediff
  module Output
    module Preview
      # @rubocop:disable Metrics/ClassLength
      class ParameterGenerator
        DateUtil = Recediff::Util::DateUtil

        # @param digitalized_receipt [Recediff::Model::ReceiptComputer::DigitalizedReceipt]
        # @return [Parameter::DigitalizedReceipt]
        def from_digitalized_receipt(digitalized_receipt)
          parameterized_audit_payer = Parameter::AuditPayer.from(digitalized_receipt.audit_payer)
          parameterized_hospital    = Parameter::Hospital.from(digitalized_receipt.hospital)
          parameterized_prefecture  = Parameter::Prefecture.from(digitalized_receipt.hospital.prefecture)

          Parameter::DigitalizedReceipt.new(
            seikyuu_ym:  Parameter::Month.from(digitalized_receipt.seikyuu_ym),
            audit_payer: parameterized_audit_payer,
            hospital:    parameterized_hospital,
            prefecture:  parameterized_prefecture,
            receipts:    []
          ).tap do | parameterized_digitalized_receipt |
            parameterized_digitalized_receipt.receipts = digitalized_receipt.map do | receipt |
              convert_receipt(receipt, parameterized_audit_payer, parameterized_hospital, parameterized_prefecture)
            end
          end
        end

        # @param receipt [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt]
        # @param parameterized_audit_payer [Parameter::AuditPayer]
        # @param parameterized_hospital [Parameter::Hospital]
        # @param parameterized_prefecture [Parameter::Prefecture]
        # @return [Parameter::Receipt]
        def convert_receipt(receipt, parameterized_audit_payer, parameterized_hospital, parameterized_prefecture)
          Parameter::Receipt.new(
            id:                receipt.id,
            shinryou_ym:       Parameter::Month.from(receipt.shinryou_ym),
            nyuugai:           receipt.nyuuin? ? :nyuugai : :gairai,
            audit_payer:       parameterized_audit_payer,
            prefecture:        parameterized_prefecture,
            hospital:          parameterized_hospital,
            type:              Parameter::Type.from(receipt.type),
            tokki_jikous:      [],
            patient:           Parameter::Patient.from(receipt.patient),
            hokens:            convert_applied_hoken_list(
              receipt.iryou_hoken,
              receipt.kouhi_futan_iryous
            ),
            shoubyoumeis:      [],
            tekiyou:           Parameter::Tekiyou.new,
            ryouyou_no_kyuufu: []
          ).tap do | parameterized_receipt |
            # 特記事項
            parameterized_receipt.tokki_jikous = receipt.tokki_jikous.values.map { | tokki_jikou | Parameter::TokkiJikou.from(tokki_jikou) }
            # 傷病名
            parameterized_receipt.shoubyoumeis = convert_shoubyoumeis(receipt.shoubyoumeis)
            # 摘要欄
          end
        end

        # @param receipt [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt]
        # @param audit_payer [Recediff::Model::ReceiptComputer::DigitalizedReceipt::AuditPayer]
        # @rubocop:disable Metrics/MethodLength
        def __convert_receipt(receipt)
          {
            shoubyoumeis:        convert_shoubyoumeis(receipt.shoubyoumeis),
            tekiyou:             convert_tekiyou(receipt),
            point_summary_board: calculate_summary_of(receipt),
            ryouyou_no_kyuufu:   {
              iryou_hoken:        ryouyou_no_kyuufu_convert_iryou_hoken(receipt.iryou_hoken),
              kouhi_futan_iryous: ryouyou_no_kyuufu_convert_kouhi_futan_iryous(receipt.kouhi_futan_iryous),
            },
          }
        end

        # @param iryou_hoken [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::IryouHoken]
        # @param kouhi_futan_iryous [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::KouhiFutanIryou>]
        def convert_applied_hoken_list(iryou_hoken, kouhi_futan_iryous)
          Parameter::AppliedHokenList.new(
            iryou_hoken:        iryou_hoken ? Parameter::IryouHoken.from(iryou_hoken) : nil,
            kouhi_futan_iryous: kouhi_futan_iryous.map { | kouhi_futan_iryou | Parameter::KouhiFutanIryou.from(kouhi_futan_iryou) }
          )
        end

        # @param iryou_hoken [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::IryouHoken]
        def ryouyou_no_kyuufu_convert_iryou_hoken(iryou_hoken)
          {
            goukei_tensuu:                           iryou_hoken&.goukei_tensuu,
            shinryou_jitsunissuu:                    iryou_hoken&.shinryou_jitsunissuu,
            ichibu_futankin:                         iryou_hoken&.ichibu_futankin,
            kyuufu_taishou_ichibu_futankin:          iryou_hoken&.kyuufu_taishou_ichibu_futankin,
            shokuji_seikatsu_ryouyou_kaisuu:         iryou_hoken&.shokuji_seikatsu_ryouyou_kaisuu,
            shokuji_seikatsu_ryouyou_goukei_kingaku: iryou_hoken&.shokuji_seikatsu_ryouyou_goukei_kingaku,
          }
        end

        # @param kouhi_futan_iryous [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::KouhiFutanIryou>]
        def ryouyou_no_kyuufu_convert_kouhi_futan_iryous(kouhi_futan_iryous)
          # @param kouhi_futan_iryou [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::KouhiFutanIryou]
          # @param index [Integer]
          kouhi_futan_iryous.map do | kouhi_futan_iryou |
            {
              goukei_tensuu:                           kouhi_futan_iryou.goukei_tensuu,
              shinryou_jitsunissuu:                    kouhi_futan_iryou.shinryou_jitsunissuu,
              ichibu_futankin:                         kouhi_futan_iryou.ichibu_futankin,
              kyuufu_taishou_ichibu_futankin:          kouhi_futan_iryou.kyuufu_taishou_ichibu_futankin,
              shokuji_seikatsu_ryouyou_kaisuu:         kouhi_futan_iryou.shokuji_seikatsu_ryouyou_kaisuu,
              shokuji_seikatsu_ryouyou_goukei_kingaku: kouhi_futan_iryou.shokuji_seikatsu_ryouyou_goukei_kingaku,
            }
          end
        end

        # @param shoubyoumeis [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Shoubyoumei>]
        # @return [Array<Parameter::GroupedShoubyoumeiList>]
        def convert_shoubyoumeis(shoubyoumeis)
          sorter = proc do | grouped_list, _ |
            [grouped_list.main? ? 0 : 1, grouped_list.start_date.year, grouped_list.start_date.month ,grouped_list.start_date.day, grouped_list.tenki.code]
          end

          # @param shoubyoumei [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Shoubyoumei]
          shoubyoumeis.group_by do | shoubyoumei |
            Parameter::GroupedShoubyoumeiList.new(
              start_date:   Parameter::Date.from(shoubyoumei.start_date),
              tenki:        Parameter::Tenki.from(shoubyoumei.tenki),
              is_main:      shoubyoumei.main?,
              shoubyoumeis: []
            )
          # @param grouped_list [Parameter::GroupedShoubyoumeiList]
          # @param shoubyoumeis [<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Shoubyoumei>]
          end.sort_by(&sorter).each do | grouped_list, shoubyoumeis |
            grouped_list.shoubyoumeis = shoubyoumeis
              .sort_by(&:code)
              .map { | shoubyoumei | Parameter::Shoubyoumei.from(shoubyoumei) }
              # .group_by.with_index { | _, index | index / 5 } # 文字数の上限判定ロジックが必要
              # .values
          end.to_h.keys
        end

        # @param receipt [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt]
        def convert_tekiyou(receipt)
          receipt.map do | shinryou_shikibetsu, ichiren_units |
            {
              shinryou_shikibetsu: {
                code: shinryou_shikibetsu.code,
                name: shinryou_shikibetsu.name,
              },
              # @param ichiren [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::IchirenUnit]
              ichiren_units:       ichiren_units.map do | ichiren |
                {
                  futan_kubun:  ichiren.futan_kubun.code,
                  # @param santei_unit [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
                  santei_units: ichiren.map do | santei_unit |
                    {
                      tensuu: santei_unit.tensuu,
                      kaisuu: santei_unit.kaisuu,
                      # @param item [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::Cost,
                      #              Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::Comment]
                      items:  santei_unit.map do | item |
                        {
                          item:   {
                            type:       item.type,
                            code:       item.code.value,
                            name:       item.name,
                            shiyouryou: item.shiyouryou,
                            unit:       item.unit ? {
                              code: item.unit&.code,
                              name: item.unit&.name,
                            } : nil,
                          },
                          tensuu: item.tensuu,
                          kaisuu: item.kaisuu,
                        }
                      end,
                    }
                  end,
                }
              end,
            }
          end.sort_by { | s | s[:shinryou_shikibetsu][:code].to_s.to_i }
        end

        def calculate_summary_of(_receipt)
          'pending'
        end
      end
    end
  end
end
