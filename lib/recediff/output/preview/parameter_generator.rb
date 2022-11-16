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
            tokki_jikous:      receipt.tokki_jikous.values.map { | tokki_jikou | Parameter::TokkiJikou.from(tokki_jikou) },
            patient:           Parameter::Patient.from(receipt.patient),
            hokens:            convert_applied_hoken_list(receipt.hoken_list),
            shoubyoumeis:      convert_shoubyoumeis(receipt.shoubyoumeis),
            tekiyou:           convert_tekiyou(receipt),
            ryouyou_no_kyuufu: convert_ryouyou_no_kyuufu(receipt.hoken_list)
          ).tap do | parameterized_receipt |
            # 摘要欄
          end
        end

        # @param applied_hoken_list [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::AppliedHokenList]
        def convert_applied_hoken_list(applied_hoken_list)
          iryou_hoken        = applied_hoken_list.iryou_hoken
          kouhi_futan_iryous = applied_hoken_list.kouhi_futan_iryous
          Parameter::AppliedHokenList.new(
            iryou_hoken:        iryou_hoken ? Parameter::IryouHoken.from(iryou_hoken) : nil,
            kouhi_futan_iryous: kouhi_futan_iryous.map { | kouhi_futan_iryou | Parameter::KouhiFutanIryou.from(kouhi_futan_iryou) }
          )
        end

        # @param applied_hoken_list [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::AppliedHokenList]
        def convert_ryouyou_no_kyuufu(applied_hoken_list)
          list = Parameter::RyouyouNoKyuufuList.new

          if (iryou_hoken = applied_hoken_list.iryou_hoken)
            list.iryou_hoken = Parameter::RyouyouNoKyuufu.new(
              goukei_tensuu:                           iryou_hoken.goukei_tensuu,
              shinryou_jitsunissuu:                    iryou_hoken.shinryou_jitsunissuu,
              ichibu_futankin:                         iryou_hoken.ichibu_futankin,
              kyuufu_taishou_ichibu_futankin:          iryou_hoken.kyuufu_taishou_ichibu_futankin,
              shokuji_seikatsu_ryouyou_kaisuu:         iryou_hoken.shokuji_seikatsu_ryouyou_kaisuu,
              shokuji_seikatsu_ryouyou_goukei_kingaku: iryou_hoken.shokuji_seikatsu_ryouyou_goukei_kingaku
            )
          end

          list.kouhi_futan_iryous = []
          applied_hoken_list.kouhi_futan_iryous.map do | kouhi_futan_iryou |
            list.kouhi_futan_iryous << Parameter::RyouyouNoKyuufu.new(
              goukei_tensuu:                           kouhi_futan_iryou.goukei_tensuu,
              shinryou_jitsunissuu:                    kouhi_futan_iryou.shinryou_jitsunissuu,
              ichibu_futankin:                         kouhi_futan_iryou.ichibu_futankin,
              kyuufu_taishou_ichibu_futankin:          kouhi_futan_iryou.kyuufu_taishou_ichibu_futankin,
              shokuji_seikatsu_ryouyou_kaisuu:         kouhi_futan_iryou.shokuji_seikatsu_ryouyou_kaisuu,
              shokuji_seikatsu_ryouyou_goukei_kingaku: kouhi_futan_iryou.shokuji_seikatsu_ryouyou_goukei_kingaku
            )
          end

          list
        end

        # @param shoubyoumeis [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Shoubyoumei>]
        # @return [Array<Parameter::GroupedShoubyoumeiList>]
        def convert_shoubyoumeis(shoubyoumeis)
          sorter = proc do | grouped_list, _ |
            [
              grouped_list.main? ? 0 : 1,
              grouped_list.start_date.year,
              grouped_list.start_date.month,
              grouped_list.start_date.day,
              grouped_list.tenki.code,
            ]
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
          Parameter::Tekiyou.new(
            shinryou_shikibetsu_sections: receipt.map do | shinryou_shikibetsu, ichiren_units |
              Parameter::ShinryouShikibetsuSection.new(
                shinryou_shikibetsu: Parameter::ShinryouShikibetsu.from(shinryou_shikibetsu),
                ichiren_units:       ichiren_units.map { | ichiren_unit | convert_ichiren_unit(ichiren_unit) }
              )
            end.sort_by { | section | section.shinryou_shikibetsu.code }
          )
        end

        # @param ichiren_unit [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::IchirenUnit]
        # @return [Parameter::IchirenUnit]
        def convert_ichiren_unit(ichiren_unit)
          Parameter::IchirenUnit.new(
            futan_kubun:  ichiren_unit.futan_kubun.code,
            santei_units: ichiren_unit.map { | santei_unit | convert_santei_unit(santei_unit) }
          )
        end

        # @param santei_unit [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
        # @return [Parameter::SanteiUnit]
        def convert_santei_unit(santei_unit)
          Parameter::SanteiUnit.new(
            tensuu: santei_unit.tensuu,
            kaisuu: santei_unit.kaisuu,
            items:  santei_unit.map { | tekiyou_item | convert_tekiyou_item(tekiyou_item) }
          )
        end

        # @param tekiyou_item [
        #   Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::Cost,
        #   Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::Comment
        # ]
        def convert_tekiyou_item(tekiyou_item)
          Parameter::TekiyouItem.new(
            tensuu: tekiyou_item.tensuu,
            kaisuu: tekiyou_item.kaisuu,
            treat:  Parameter::Treat.new(
              shiyouryou: tekiyou_item.shiyouryou,
              text:       '%s %s%s' % [tekiyou_item, tekiyou_item.shiyouryou, tekiyou_item.unit&.name],
              item:       Parameter::TreatmentItem.new(
                type: tekiyou_item.type,
                code: tekiyou_item.code.value,
                name: tekiyou_item.name,
                unit: tekiyou_item.unit ? Parameter::Unit.from(tekiyou_item.unit) : nil
              )
            )
          )
        end

        def calculate_summary_of(_receipt)
          'pending'
        end
      end
    end
  end
end
