# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      # rubocop:disable Metrics/ModuleLength
      module Parameter
        module Common
          CodedItem              = Struct.new(:code, :name, keyword_init: true)
          CodedItemWithShortName = Struct.new(:code, :name, :short_name, keyword_init: true)

          # 年月日

          Date = Struct.new(:year, :month, :day, :wareki, keyword_init: true) do
            class << self
              # @param month [::Date]
              def from(date)
                new(
                  year:   date.year,
                  month:  date.month,
                  day:    date.day,
                  wareki: WarekiDate.from(date)
                )
              end
            end
          end
          Month = Struct.new(:year, :month, :wareki, keyword_init: true) do
            class << self
              # @param month [::Month]
              # @return [self]
              def from(month)
                new(
                  year:   month.year,
                  month:  month.month,
                  wareki: WarekiMonth.from(month)
                )
              end
            end
          end
          WarekiDate = Struct.new(:gengou, :year, :month, :day, :text, keyword_init: true) do
            class << self
              # @param date [::Date]
              def from(date)
                jisx0301 = date.jisx0301
                new(
                  gengou: WarekiGengou.from(date),
                  year:   jisx0301[1, 2].to_i,
                  month:  date.month,
                  day:    date.day,
                  text:   Util::DateUtil.to_wareki(date, zenkaku: true)
                )
              end
            end
          end
          WarekiMonth = Struct.new(:gengou, :year, :month, :text, keyword_init: true) do
            class << self
              # @param month [::Month]
              def from(month)
                new(
                  gengou: WarekiGengou.from(::Date.new(month.year, month.month, month.length)),
                  year:   month.year,
                  month:  month.month,
                  text:   Util::DateUtil.to_wareki(month, zenkaku: true)
                )
              end
            end
          end
          WarekiGengou = Struct.new(:code, :name, :short_name, :alphabet, :base_year, keyword_init: true) do
            class << self
              # @param month [::Date]
              def from(date)
                gengou = Util::DateUtil::Gengou.find_by_alphabet(date.jisx0301[0])
                new(
                  code:       gengou.code,
                  name:       gengou.name,
                  short_name: gengou.short_name,
                  alphabet:   gengou.alphabet,
                  base_year:  gengou.base_year
                )
              end
            end
          end

          # 電子レセプトファイル(請求書)レベル

          DigitalizedReceipt = Struct.new(
            :seikyuu_ym,
            :audit_payer,
            :hospital,
            :prefecture,
            :receipts,
            keyword_init: true
          )
          Hospital = Struct.new(:code, :name, :tel, :address, keyword_init: true) do
            class << self
              # @param hospital [Model::ReceiptComputer::DigitalizedReceipt::Hospital]
              # @return [self]
              def from(hospital)
                new(
                  code:    hospital.code,
                  name:    hospital.name,
                  tel:     hospital.tel,
                  address: hospital.address
                )
              end
            end
          end

          class AuditPayer < CodedItemWithShortName
            class << self
              # @param audit_payer [Model::ReceiptComputer::DigitalizedReceipt::AuditPayer]
              # @return [self]
              def from(audit_payer)
                new(
                  code:       audit_payer.code,
                  name:       audit_payer.name,
                  short_name: audit_payer.short_name
                )
              end
            end
          end

          # レセプト(明細書)レベル

          Receipt = Struct.new(
            :id,
            :shinryou_ym,
            :nyuugai,
            :audit_payer,
            :prefecture,
            :hospital,
            :type,
            :patient,
            :tokki_jikous,
            :hokens,
            :shoubyoumeis,
            :tekiyou,
            :ryouyou_no_kyuufu,
            :tensuu_shuukei,
            keyword_init: true
          )
          Patient = Struct.new(:id, :name, :name_kana, :sex, :birth_date, keyword_init: true) do
            class << self
              def from(patient)
                new(
                  id:         patient.id,
                  name:       patient.name,
                  name_kana:  patient.name_kana,
                  sex:        Sex.from(patient.sex),
                  birth_date: Date.from(patient.birth_date)
                )
              end
            end
          end
          Type = Struct.new(
            :tensuu_hyou_type,
            :main_hoken_type,
            :hoken_multiple_type,
            :patient_age_type,
            keyword_init: true
          ) do
            class << self
              # @param type [Model::ReceiptComputer::DigitalizedReceipt::Receipt::Type]
              # @return [self]
              def from(type)
                new(
                  tensuu_hyou_type:    TensuuHyouType.from(type.tensuu_hyou_type),
                  main_hoken_type:     MainHokenType.from(type.main_hoken_type),
                  hoken_multiple_type: HokenMultipleType.from(type.hoken_multiple_type),
                  patient_age_type:    PatientAgeType.from(type.patient_age_type)
                )
              end
            end
          end
          module CodedItemFactory
            def from(object)
              new(
                code: object.code,
                name: object.name
              )
            end
          end

          class TensuuHyouType < CodedItem
            extend CodedItemFactory
          end

          class MainHokenType < CodedItem
            extend CodedItemFactory
          end

          class HokenMultipleType < CodedItem
            extend CodedItemFactory
          end

          class PatientAgeType < CodedItem
            extend CodedItemFactory
          end

          class TokkiJikou < CodedItem
            extend CodedItemFactory
          end

          class Prefecture < CodedItemWithShortName
            class << self
              # @param prefecture [Model::ReceiptComputer::DigitalizedReceipt::Prefecture]
              # @return [self]
              def from(prefecture)
                new(
                  code:       prefecture.code,
                  name:       prefecture.name,
                  short_name: prefecture.name_without_suffix
                )
              end
            end
          end

          class Sex < CodedItemWithShortName
            class << self
              # @param sex [Model::ReceiptComputer::DigitalizedReceipt::Sex]
              # @return [self]
              def from(sex)
                new(
                  code:       sex.code,
                  name:       sex.name,
                  short_name: sex.short_name
                )
              end
            end
          end

          # 保険

          AppliedHokenList = Struct.new(:iryou_hoken, :kouhi_futan_iryous, keyword_init: true)
          IryouHoken       = Struct.new(
            :hokenja_bangou,
            :kigou,
            :bangou,
            :edaban,
            :kyuufu_wariai,
            :teishotoku_kubun,
            keyword_init: true
          ) do
            class << self
              # @param iryou_hoken [Model::ReceiptComputer::DigitalizedReceipt::Receipt::IryouHoken]
              # @return [self]
              def from(iryou_hoken)
                new(
                  hokenja_bangou:   iryou_hoken.hokenja_bangou,
                  kigou:            iryou_hoken.kigou,
                  bangou:           iryou_hoken.bangou,
                  edaban:           iryou_hoken.edaban,
                  kyuufu_wariai:    iryou_hoken.kyuufu_wariai,
                  teishotoku_kubun: iryou_hoken.teishotoku_kubun
                )
              end
            end
          end
          KouhiFutanIryou = Struct.new(:futansha_bangou, :jukyuusha_bangou, keyword_init: true) do
            class << self
              # @param kouhi_futan_iryou [Model::ReceiptComputer::DigitalizedReceipt::Receipt::KouhiFutanIryou]
              # @return [self]
              def from(kouhi_futan_iryou)
                new(
                  futansha_bangou:  kouhi_futan_iryou.futansha_bangou,
                  jukyuusha_bangou: kouhi_futan_iryou.jukyuusha_bangou
                )
              end
            end
          end

          # 傷病名

          GroupedShoubyoumeiList = Struct.new(:start_date, :tenki, :is_main, :shoubyoumeis, keyword_init: true)
          Shoubyoumei = Struct.new(
            :master_shoubyoumei,
            :master_shuushokugos,
            :text,
            :full_text,
            :is_main,
            :is_worpro,
            :start_date,
            :tenki,
            :comment,
            keyword_init: true
          ) do
            class << self
              # @param shoubyoumei [Model::ReceiptComputer::DigitalizedReceipt::Receipt::Shoubyoumei]
              def from(shoubyoumei)
                new(
                  master_shoubyoumei:  MasterShoubyoumei.from(shoubyoumei.master_shoubyoumei),
                  master_shuushokugos: shoubyoumei.master_shuushokugos.map do | shuushokugo |
                    MasterShuushokugo.from(shuushokugo)
                  end,
                  text:                shoubyoumei.to_s,
                  full_text:           '%s%s%s' % [
                    shoubyoumei,
                    shoubyoumei.main? ? '（主）' : '',
                    "（#{shoubyoumei.comment}）".sub(/（）\z/, ''),
                  ],
                  is_main:             shoubyoumei.main?,
                  is_worpro:           shoubyoumei.worpro?,
                  start_date:          Date.from(shoubyoumei.start_date),
                  tenki:               Tenki.from(shoubyoumei.tenki),
                  comment:             shoubyoumei.comment
                )
              end
            end

            def is_main
              is_main
            end

            def worpro?
              is_worpro
            end
          end
          MasterShoubyoumei = Struct.new(:code, :name, keyword_init: true) do
            class << self
              # @param master_shoubyoumei [Model::ReceiptComputer::Master::Diagnosis::Shoubyoumei]
              def from(master_shoubyoumei)
                new(
                  code: master_shoubyoumei.code.value,
                  name: master_shoubyoumei.name
                )
              end
            end
          end
          MasterShuushokugo = Struct.new(:code, :name, :is_prefix, keyword_init: true) do
            class << self
              # @param master_shuushokugo [Model::ReceiptComputer::Master::Diagnosis::Shuushokugo]
              def from(master_shuushokugo)
                new(
                  code:      master_shuushokugo.code.value,
                  name:      master_shuushokugo.name,
                  is_prefix: master_shuushokugo.is_prefix
                )
              end
            end
          end
          class Tenki < CodedItem
            extend CodedItemFactory
          end

          # 点数欄

          # @param section [Symbol] 診療識別または「診療識別 > 手技/薬剤」
          TensuuShuukei             = Struct.new(:sections, keyword_init: true)
          TensuuShuukeiSection      = Struct.new(:section, :hokens, keyword_init: true)
          CombinedTensuuShuukeiUnit = Struct.new(
            :key,
            :tensuu,
            :total_kaisuu,
            :total_tensuu,
            :units,
            keyword_init: true
          )
          TensuuShuukeiUnit = Struct.new(
            :tensuu,
            :total_kaisuu,
            :total_tensuu,
            keyword_init: true
          )

          # 摘要欄

          Tekiyou                   = Struct.new(:shinryou_shikibetsu_sections, keyword_init: true)
          ShinryouShikibetsuSection = Struct.new(:shinryou_shikibetsu, :ichiren_units, keyword_init: true)
          class ShinryouShikibetsu < CodedItem
            extend CodedItemFactory
          end
          IchirenUnit    = Struct.new(:futan_kubun, :santei_units, keyword_init: true)
          SanteiUnit     = Struct.new(:tensuu, :kaisuu, :items, keyword_init: true)

          # 診療行為

          ShinryouKoui = Struct.new(
            :type,
            :master,
            :text,
            :shiyouryou,
            :unit,
            keyword_init: true
          )
          MasterShinryouKoui = Struct.new(
            :code,
            :name,
            # :point,
            # :point_type,
            :unit,
            keyword_init: true
          )

          # 医薬品

          Iyakuhin = Struct.new(
            :type,
            :master,
            :text,
            :shiyouryou,
            :unit,
            keyword_init: true
          )
          MasterIyakuhin = Struct.new(
            :code,
            :name,
            # :price,
            # :price_type,
            :unit,
            keyword_init: true
          )

          # 特定器材

          TokuteiKizai = Struct.new(
            :type,
            :master,
            :product_name,
            :text,
            :shiyouryou,
            :unit_price,
            :unit,
            keyword_init: true
          )
          MasterTokuteiKizai = Struct.new(
            :code,
            :name,
            :price,
            :price_type,
            :unit,
            keyword_init: true
          )

          # コメント

          Comment = Struct.new(
            :type,
            :master,
            :text,
            :appended_content,
            keyword_init: true
          )
          MasterComment = Struct.new(
            :code,
            :pattern,
            :name,
            keyword_init: true
          )
          AppendedContent = Struct.new(:text, keyword_init: true)

          class Unit < CodedItem
            extend CodedItemFactory
          end

          # 療養の給付欄

          RyouyouNoKyuufuList = Struct.new(:iryou_hoken, :kouhi_futan_iryous, keyword_init: true)
          RyouyouNoKyuufu     = Struct.new(
            :goukei_tensuu,
            :shinryou_jitsunissuu,
            :ichibu_futankin,
            :kyuufu_taishou_ichibu_futankin,
            :shokuji_seikatsu_ryouyou_kaisuu,
            :shokuji_seikatsu_ryouyou_goukei_kingaku,
            keyword_init: true
          )

          class << self
            DateUtil           = Receiptisan::Util::DateUtil
            DigitalizedReceipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt

            # @param digitalized_receipt [DigitalizedReceipt]
            # @return [Common::DigitalizedReceipt]
            def from_digitalized_receipt(digitalized_receipt)
              parameterized_audit_payer = Common::AuditPayer.from(digitalized_receipt.audit_payer)
              parameterized_hospital    = Common::Hospital.from(digitalized_receipt.hospital)
              parameterized_prefecture  = Common::Prefecture.from(digitalized_receipt.hospital.prefecture)

              Common::DigitalizedReceipt.new(
                seikyuu_ym:  Common::Month.from(digitalized_receipt.seikyuu_ym),
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

            # @param receipt [DigitalizedReceipt::Receipt]
            # @param parameterized_audit_payer [Common::AuditPayer]
            # @param parameterized_hospital [Common::Hospital]
            # @param parameterized_prefecture [Common::Prefecture]
            # @return [Common::Receipt]
            def convert_receipt(receipt, parameterized_audit_payer, parameterized_hospital, parameterized_prefecture)
              Common::Receipt.new(
                id:                receipt.id,
                shinryou_ym:       Common::Month.from(receipt.shinryou_ym),
                nyuugai:           receipt.nyuuin? ? :nyuuin : :gairai,
                audit_payer:       parameterized_audit_payer,
                prefecture:        parameterized_prefecture,
                hospital:          parameterized_hospital,
                type:              Common::Type.from(receipt.type),
                tokki_jikous:      receipt.tokki_jikous.values.map do | tokki_jikou |
                  Common::TokkiJikou.from(tokki_jikou)
                end,
                patient:           Common::Patient.from(receipt.patient),
                hokens:            convert_applied_hoken_list(receipt.hoken_list),
                shoubyoumeis:      convert_shoubyoumeis(receipt.shoubyoumeis),
                tekiyou:           convert_tekiyou(receipt),
                ryouyou_no_kyuufu: convert_ryouyou_no_kyuufu(receipt.hoken_list),
                tensuu_shuukei:    convert_tensuu_shuukei(receipt)
              )
            end

            # @param applied_hoken_list [DigitalizedReceipt::Receipt::AppliedHokenList]
            def convert_applied_hoken_list(applied_hoken_list)
              iryou_hoken        = applied_hoken_list.iryou_hoken
              kouhi_futan_iryous = applied_hoken_list.kouhi_futan_iryous
              Common::AppliedHokenList.new(
                iryou_hoken:        iryou_hoken ? Common::IryouHoken.from(iryou_hoken) : nil,
                kouhi_futan_iryous: kouhi_futan_iryous.map do | kouhi_futan_iryou |
                  Common::KouhiFutanIryou.from(kouhi_futan_iryou)
                end
              )
            end

            # @param applied_hoken_list [DigitalizedReceipt::Receipt::AppliedHokenList]
            def convert_ryouyou_no_kyuufu(applied_hoken_list)
              list = Common::RyouyouNoKyuufuList.new

              if (iryou_hoken = applied_hoken_list.iryou_hoken)
                list.iryou_hoken = Common::RyouyouNoKyuufu.new(
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
                list.kouhi_futan_iryous << Common::RyouyouNoKyuufu.new(
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

            # @param shoubyoumeis [Array<DigitalizedReceipt::Receipt::Shoubyoumei>]
            # @return [Array<Common::GroupedShoubyoumeiList>]
            def convert_shoubyoumeis(shoubyoumeis)
              sorter = proc do | grouped_list, _ |
                [
                  grouped_list.is_main ? 0 : 1,
                  grouped_list.start_date.year,
                  grouped_list.start_date.month,
                  grouped_list.start_date.day,
                  grouped_list.tenki.code,
                ]
              end

              # @param shoubyoumei [DigitalizedReceipt::Receipt::Shoubyoumei]
              shoubyoumeis.group_by do | shoubyoumei |
                Common::GroupedShoubyoumeiList.new(
                  start_date:   Common::Date.from(shoubyoumei.start_date),
                  tenki:        Common::Tenki.from(shoubyoumei.tenki),
                  is_main:      shoubyoumei.main?,
                  shoubyoumeis: []
                )
                # @param grouped_list [Common::GroupedShoubyoumeiList]
                # @param shoubyoumeis [<DigitalizedReceipt::Receipt::Shoubyoumei>]
              end.sort_by(&sorter).each do | grouped_list, shoubyoumei_list |
                grouped_list.shoubyoumeis = shoubyoumei_list
                  .sort_by(&:code)
                  .map { | shoubyoumei | Common::Shoubyoumei.from(shoubyoumei) }
              end.to_h.keys
            end

            # @param receipt [DigitalizedReceipt::Receipt]
            def convert_tekiyou(receipt)
              Common::Tekiyou.new(
                shinryou_shikibetsu_sections: receipt.map do | _, ichiren_units |
                  Common::ShinryouShikibetsuSection.new(
                    shinryou_shikibetsu: Common::ShinryouShikibetsu.from(ichiren_units.first.shinryou_shikibetsu),
                    ichiren_units:       ichiren_units.map { | ichiren_unit | convert_ichiren_unit(ichiren_unit) }
                  )
                end.sort_by { | section | section.shinryou_shikibetsu.code }
              )
            end

            # @param ichiren_unit [DigitalizedReceipt::Receipt::Tekiyou::IchirenUnit]
            # @return [Common::IchirenUnit]
            def convert_ichiren_unit(ichiren_unit)
              Common::IchirenUnit.new(
                futan_kubun:  ichiren_unit.futan_kubun.code,
                santei_units: ichiren_unit.map { | santei_unit | convert_santei_unit(santei_unit) }
              )
            end

            # @param santei_unit [DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
            # @return [Common::SanteiUnit]
            def convert_santei_unit(santei_unit)
              parameterized_santei_unit = Common::SanteiUnit.new(
                tensuu: santei_unit.tensuu,
                kaisuu: santei_unit.kaisuu,
                items:  []
              )
              santei_unit.each do | tekiyou_item |
                parameterized_santei_unit.items << convert_tekiyou_item(tekiyou_item)
                next if tekiyou_item.comment?

                tekiyou_item.each_comment do | comment |
                  parameterized_santei_unit.items << convert_tekiyou_item(comment)
                end
              end

              parameterized_santei_unit
            end

            # @param tekiyou_item [
            #   DigitalizedReceipt::Receipt::Tekiyou::Cost,
            #   DigitalizedReceipt::Receipt::Tekiyou::Comment
            # ]
            def convert_tekiyou_item(tekiyou_item)
              case tekiyou_item
              when DigitalizedReceipt::Receipt::Tekiyou::Comment
                convert_comment(tekiyou_item)
              else
                case tekiyou_item.resource
                when DigitalizedReceipt::Receipt::Tekiyou::Resource::ShinryouKoui
                  convert_shinryou_koui(tekiyou_item)
                when DigitalizedReceipt::Receipt::Tekiyou::Resource::Iyakuhin
                  convert_iyakuhin(tekiyou_item)
                when DigitalizedReceipt::Receipt::Tekiyou::Resource::TokuteiKizai
                  convert_tokutei_kizai(tekiyou_item)
                end
              end
            end

            # @param tekiyou_shinryou_koui [DigitalizedReceipt::Receipt::Tekiyou::Cost]
            def convert_shinryou_koui(tekiyou_shinryou_koui)
              resource = tekiyou_shinryou_koui.resource
              unit     = resource.unit ? Common::Unit.from(resource.unit) : nil

              Common::ShinryouKoui.new(
                type:       :shinryou_koui,
                master:     Common::MasterShinryouKoui.new(
                  code: resource.code.value,
                  name: resource.name,
                  unit: unit
                ),
                text:       resource2text(resource),
                shiyouryou: resource.shiyouryou,
                unit:       unit
              )
            end

            # @param tekiyou_iyakuhin [DigitalizedReceipt::Receipt::Tekiyou::Cost]
            def convert_iyakuhin(tekiyou_iyakuhin)
              resource = tekiyou_iyakuhin.resource
              unit     = resource.unit ? Common::Unit.from(resource.unit) : nil

              Common::Iyakuhin.new(
                type:       :iyakuhin,
                master:     Common::MasterIyakuhin.new(
                  code: resource.code.value,
                  name: resource.name,
                  unit: unit
                ),
                text:       resource2text(resource),
                shiyouryou: resource.shiyouryou,
                unit:       unit
              )
            end

            # @param tekiyou_tokutei_kizai [DigitalizedReceipt::Receipt::Tekiyou::Cost]
            def convert_tokutei_kizai(tekiyou_tokutei_kizai)
              resource = tekiyou_tokutei_kizai.resource
              unit     = resource.unit ? Common::Unit.from(resource.unit) : nil

              Common::TokuteiKizai.new(
                type:         :tokutei_kizai,
                master:       Common::MasterTokuteiKizai.new(
                  code:       resource.code.value,
                  name:       resource.name,
                  price:      resource.unit_price,
                  price_type: resource.price_type,
                  unit:       unit
                ),
                product_name: resource.product_name,
                text:         'pending',
                shiyouryou:   resource.shiyouryou,
                unit_price:   resource.unit_price,
                unit:         unit
              )
            end

            # @param tekiyou_comment [DigitalizedReceipt::Receipt::Tekiyou::Comment]
            def convert_comment(tekiyou_comment)
              Common::Comment.new(
                type:             :comment,
                master:           Common::MasterComment.new(
                  code:    tekiyou_comment.code.value,
                  name:    tekiyou_comment.name,
                  pattern: tekiyou_comment.pattern.code
                ),
                text:             tekiyou_comment.format,
                appended_content: tekiyou_comment.appended_content&.then do | content |
                  Common::AppendedContent.new(text: content.to_s)
                end
              )
            end

            def convert_tensuu_shuukei(_receipt); end

            private

            def resource2text(resource)
              return resource.name unless (unit = resource.unit)

              shiyouryou = resource.shiyouryou.to_i == resource.shiyouryou ?
                resource.shiyouryou.to_i :
                resource.shiyouryou

              resource.name + '　%s%s' % [hankaku2zenkaku(shiyouryou), unit.name]
            end

            def hankaku2zenkaku(hankaku_number)
              hankaku_number.to_s.tr('0-9', '０-９')
            end
          end
        end
        # rubocop:enable Metrics/ModuleLength
      end
    end
  end
end
