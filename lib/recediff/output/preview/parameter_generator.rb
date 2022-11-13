# frozen_string_literal: true

module Recediff
  module Output
    module Preview
      # @rubocop:disable Metrics/ClassLength
      class ParameterGenerator
        DateUtil = Recediff::Util::DateUtil

        # @param digitalized_receipt [Recediff::Model::ReceiptComputer::DigitalizedReceipt]
        def from_digitalized_receipt(digitalized_receipt)
          audit_payer = digitalized_receipt.audit_payer
          hospital    = digitalized_receipt.hospital
          {
            seikyuu_ym:  convert_date_or_month(digitalized_receipt.seikyuu_ym),
            audit_payer: {
              code:       audit_payer.code,
              name:       audit_payer.name,
              short_name: audit_payer.short_name,
            },
            hospital:    convert_hospital(hospital),
            prefecture:  {
              code:      hospital.prefecture.code,
              name:      hospital.prefecture.name_without_suffix,
              full_name: hospital.prefecture.name,
            },
            receipts:    digitalized_receipt.map { | receipt | convert_receipt(receipt, audit_payer) },
          }
        end

        # @param receipt [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt]
        # @param audit_payer [Recediff::Model::ReceiptComputer::DigitalizedReceipt::AuditPayer]
        # @rubocop:disable Metrics/MethodLength
        def convert_receipt(receipt, audit_payer)
          {
            id:                  receipt.id,
            shinryou_ym:         convert_date_or_month(receipt.shinryou_ym),
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
            patient:             convert_patient(receipt.patient),
            hospital:            convert_hospital(receipt.hospital),
            hokens:              {
              iryou_hoken:        convert_iryou_hoken(receipt.iryou_hoken),
              kouhi_futan_iryous: convert_kouhi_futan_iryous(receipt.kouhi_futan_iryous),
            },
            shoubyoumeis:        convert_shoubyoumeis(receipt.shoubyoumeis),
            tokki_jikous:        convert_tokki_jikous(receipt.tokki_jikous),
            tekiyou:             convert_tekiyou(receipt),
            point_summary_board: calculate_summary_of(receipt),
            ryouyou_no_kyuufu:   {
              iryou_hoken:        ryouyou_no_kyuufu_convert_iryou_hoken(receipt.iryou_hoken),
              kouhi_futan_iryous: ryouyou_no_kyuufu_convert_kouhi_futan_iryous(receipt.kouhi_futan_iryous),
            },
          }
        end

        # @param hospital [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Hospital]
        def convert_hospital(hospital)
          {
            code:    hospital.code,
            name:    hospital.name,
            tel:     hospital.tel,
            address: '', # extensible
          }
        end

        # @param iryou_hoken [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::IryouHoken]
        def convert_iryou_hoken(iryou_hoken)
          return unless iryou_hoken

          {
            hokenja_bangou:   iryou_hoken.hokenja_bangou,
            kigou:            iryou_hoken.kigou,
            bangou:           iryou_hoken.bangou,
            edaban:           iryou_hoken.edaban,
            kyuufu_wariai:    iryou_hoken.kyuufu_wariai,
            teishotoku_kubun: iryou_hoken.teishotoku_kubun,
          }
        end

        # @param kouhi_futan_iryous [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::KouhiFutanIryou>]
        def convert_kouhi_futan_iryous(kouhi_futan_iryous)
          # @param kouhi_futan_iryou [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::KouhiFutanIryou]
          # @param index [Integer]
          kouhi_futan_iryous.map do | kouhi_futan_iryou |
            {
              futansha_bangou:  kouhi_futan_iryou.futansha_bangou,
              jukyuusha_bangou: kouhi_futan_iryou.jukyuusha_bangou,
            }
          end
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

        # @param tokki_jikous [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::TokkiJikou>]
        def convert_tokki_jikous(tokki_jikous)
          # @param tokki_jikou [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::TokkiJikou]
          tokki_jikous.values.map { | tokki_jikou | { code: tokki_jikou.code, name: tokki_jikou.name } }
        end

        # @param patient [Recediff::Model::ReceiptComputer::DigitalizedReceipt::Patient]
        def convert_patient(patient)
          {
            id:         patient.id,
            name:       patient.name,
            name_kana:  patient.name_kana,
            sex:        {
              code: patient.sex.code,
              name: patient.sex.name,
            },
            birth_date: convert_date_or_month(patient.birth_date),
          }
        end

        # @param shoubyoumeis [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Shoubyoumei>]
        def convert_shoubyoumeis(shoubyoumeis)
          sorter = proc { | key, _ | [key[:is_main] ? 0 : 1, key[:start_date][:year], key[:start_date][:month] ,key[:start_date][:day], key[:tenki][:code]]} 
          # @param start_date [Date]
          # @param hash [Array<Recediff::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Shoubyoumei>]
          shoubyoumeis.group_by do | shoubyoumei |
            {
              start_date: convert_date_or_month(shoubyoumei.start_date),
              tenki:      {
                code: shoubyoumei.tenki.code,
                name: shoubyoumei.tenki.name,
              },
              is_main:    shoubyoumei.main?,
            }
          end.sort_by(&sorter).map do | key, values |
            key.merge(
              shoubyoumeis: values.sort_by(&:code)
            .map do | shoubyoumei |
              {
                name:    shoubyoumei.to_s,
                is_main: shoubyoumei.main?,
                comment: shoubyoumei.comment,
                text:    '%s%s%s' % [
                  shoubyoumei,
                  shoubyoumei.main? ? '（主）' : '',
                  "（#{shoubyoumei.comment}）".sub(/（）\z/, ''),
                ],
              }
            end
          # .group_by.with_index { | _, index | index / 5 } # 文字数の上限判定ロジックが必要
          # .values
            )
          end
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

        def convert_date_or_month(date_or_month)
          {
            year:   date_or_month.year,
            month:  date_or_month.month,
            wareki: DateUtil.to_wareki_components(date_or_month),
          }
        end

        def calculate_summary_of(_receipt)
          'pending'
        end
      end
    end
  end
end
