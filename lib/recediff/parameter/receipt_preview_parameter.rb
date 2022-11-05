# frozen_string_literal: true

module Recediff
  module Parameter
    # @rubocop:disable Metrics/ClassLength
    class ReceiptPreviewParameter
      def initialize
        @receipt = {}
      end

      # @param receipt [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt]
      # @param audit_payer [Recediff::Model::ReceiptComputer::DigitalizedReceipt::AuditPayer]
      # @rubocop:disable Metrics/MethodLength
      def from_receipt(receipt, audit_payer)
        {
          id:                  receipt.id,
          shinryou_ym:         { year: receipt.shinryou_ym.year, month: receipt.shinryou_ym.month },
          nyuugai:             receipt.nyuuin? ? :nyuuin : :gairai,
          prefecture:          {
            code:      receipt.hospital.prefecture.code,
            name:      receipt.hospital.prefecture.name_without_suffix,
            full_name: receipt.hospital.prefecture.name,
          },
          audit_payer:         {
            code: audit_payer.code,
            name: audit_payer.short_name,
          },
          type:                {
            tensuu_hyou_type:    {
              code: receipt.type.tensuu_hyou_type.code,
              name: receipt.type.tensuu_hyou_type.name,
            },
            main_hoken_type:     {
              code: receipt.type.main_hoken_type.code,
              name: receipt.type.main_hoken_type.name,
            },
            hoken_multiple_type: {
              code: receipt.type.hoken_multiple_type.code,
              name: receipt.type.hoken_multiple_type.name,
            },
            patient_age_type:    {
              code: receipt.type.patient_age_type.code,
              name: receipt.type.patient_age_type.name,
            },
          },
          patient:             from_patient(receipt.patient),
          hospital:            from_hospital(receipt.hospital),
          hokens:              {
            iryou_hoken:        from_iryou_hoken(receipt.iryou_hoken),
            kouhi_futan_iryous: from_kouhi_futan_iryous(receipt.kouhi_futan_iryous),
          },
          shoubyoumeis:        from_shoubyoumeis(receipt.shoubyoumeis),
          tokki_jikous:        from_tokki_jikous(receipt.tokki_jikous),
          tekiyou:             from_tekiyou(receipt),
          point_summary_board: calculate_summary_of(receipt),
          ryouyou_no_kyuufu:   {
            iryou_hoken:        ryouyou_no_kyuufu_from_iryou_hoken(receipt.iryou_hoken),
            kouhi_futan_iryous: ryouyou_no_kyuufu_from_kouhi_futan_iryous(receipt.kouhi_futan_iryous),
          },
        }
      end

      # @param hospital [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Hospital]
      def from_hospital(hospital)
        {
          code:    hospital.code,
          name:    hospital.name,
          tel:     hospital.tel,
          address: '', # extensible
        }
      end

      # @param iryou_hoken [Recediff::Model::ReceiptComputer::DigitalizedReceipt::IryouHoken]
      def from_iryou_hoken(iryou_hoken)
        {
          hokenja_bangou: iryou_hoken.hokenja_bangou,
          kigou:          iryou_hoken.kigou,
          bangou:         iryou_hoken.bangou,
          edaban:         iryou_hoken.edaban,
          # kyuufu_wariai: iryou_hoken.,
          # ichibu_futankin_kubun: iryou_hoken.,
        }
      end

      # @param kouhi_futan_iryous [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::KouhiFutanIryou>]
      def from_kouhi_futan_iryous(kouhi_futan_iryous)
        # @param kouhi_futan_iryou [Recediff::Model::ReceiptComputer::DigitalizedReceipt::KouhiFutanIryou]
        # @param index [Integer]
        kouhi_futan_iryous.map.with_index do | kouhi_futan_iryou, index |
          [
            (index + 1).to_s.intern,
            {
              futansha_bangou:  kouhi_futan_iryou.futansha_bangou,
              jukyuusha_bangou: kouhi_futan_iryou.jukyuusha_bangou,
            },
          ]
        end.to_h
      end

      # @param iryou_hoken [Recediff::Model::ReceiptComputer::DigitalizedReceipt::IryouHoken]
      def ryouyou_no_kyuufu_from_iryou_hoken(iryou_hoken)
        {
          goukei_tensuu:                           iryou_hoken.goukei_tensuu,
          shinryou_jitsunissuu:                    iryou_hoken.shinryou_jitsunissuu,
          ichibu_futankin:                         iryou_hoken.ichibu_futankin,
          kyuufu_taishou_ichibu_futankin:          iryou_hoken.kyuufu_taishou_ichibu_futankin,
          shokuji_seikatsu_ryouyou_kaisuu:         iryou_hoken.shokuji_seikatsu_ryouyou_kaisuu,
          shokuji_seikatsu_ryouyou_goukei_kingaku: iryou_hoken.shokuji_seikatsu_ryouyou_goukei_kingaku,
        }
      end

      # @param kouhi_futan_iryous [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::KouhiFutanIryou>]
      def ryouyou_no_kyuufu_from_kouhi_futan_iryous(kouhi_futan_iryous)
        # @param kouhi_futan_iryou [Recediff::Model::ReceiptComputer::DigitalizedReceipt::KouhiFutanIryou]
        # @param index [Integer]
        kouhi_futan_iryous.map.with_index do | kouhi_futan_iryou, index |
          [
            (index + 1).to_s.intern,
            {
              goukei_tensuu:                           kouhi_futan_iryou.goukei_tensuu,
              shinryou_jitsunissuu:                    kouhi_futan_iryou.shinryou_jitsunissuu,
              ichibu_futankin:                         kouhi_futan_iryou.ichibu_futankin,
              kyuufu_taishou_ichibu_futankin:          kouhi_futan_iryou.kyuufu_taishou_ichibu_futankin,
              shokuji_seikatsu_ryouyou_kaisuu:         kouhi_futan_iryou.shokuji_seikatsu_ryouyou_kaisuu,
              shokuji_seikatsu_ryouyou_goukei_kingaku: kouhi_futan_iryou.shokuji_seikatsu_ryouyou_goukei_kingaku,
            },
          ]
        end.to_h
      end

      # @param tokki_jikous [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::TokkiJikou>]
      def from_tokki_jikous(tokki_jikous)
        # @param tokki_jikou [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::TokkiJikou]
        tokki_jikous.map { | tokki_jikou | { code: tokki_jikou.code, name: tokki_jikou.name } }
      end

      # @param patient [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Patient]
      def from_patient(patient)
        {
          id:         patient.id,
          name:       patient.name,
          name_kana:  patient.name_kana,
          sex:        {
            code: patient.sex.code,
            name: patient.sex.name,
          },
          birth_date: patient.birth_date.jisx0301,
        }
      end

      # @param shoubyoumeis [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Shoubyoumei>]
      def from_shoubyoumeis(shoubyoumeis)
        # @param start_date [Date]
        # @param hash [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Shoubyoumei>]
        shoubyoumeis.group_by do | shoubyoumei |
          {
            start_date: {
              era:   shoubyoumei.start_date.jisx0301,
              year:  shoubyoumei.start_date.year,
              month: shoubyoumei.start_date.month,
              day:   shoubyoumei.start_date.day,
            },
            tenki:      {
              code: shoubyoumei.tenki.code,
              name: shoubyoumei.tenki.name,
            },
          }
        end.map do | key, values |
          key.merge(
            shoubyoumeis: values.sort_by(&:code)
          .map do | shoubyoumei |
            '%s%s%s' % [
              shoubyoumei,
              shoubyoumei.main? ? '（主）' : '',
              "（#{shoubyoumei.comment}）".sub('（）', ''),
            ]
          end.group_by.with_index { | _, index | index / 5 } # 文字数の上限判定ロジックが必要
            .values
          )
        end
      end

      # @param receipt [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt]
      def from_tekiyou(receipt)
        receipt.map do | shinryou_shikibetsu, ichiren_units |
          {
            shinryou_shikibetsu: {
              code: shinryou_shikibetsu.code,
              name: shinryou_shikibetsu.name,
            },
            # @param ichiren [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::IchirenUnit]
            ichiren_units:       ichiren_units.map do | ichiren |
              {
                futan_kubun:  ichiren.futan_kubun.code,
                # @param santei_unit [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::SanteiUnit]
                santei_units: ichiren.map do | santei_unit |
                  {
                    tensuu: santei_unit.tensuu,
                    kaisuu: santei_unit.kaisuu,
                    # @param item [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Cost,
                    #              Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Comment]
                    items:  santei_unit.map do | item |
                      {
                        item:   {
                          type:       item.type,
                          code:       item.code.value,
                          name:       item.name,
                          shiyouryou: item.shiyouryou,
                          unit:       {
                            code: item.unit&.code,
                            name: item.unit&.name,
                          },
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
        end
      end

      def calculate_summary_of(_receipt)
        'pending'
      end
    end
  end
end
