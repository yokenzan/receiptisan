# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        # rubocop:disable Metrics/ModuleLength
        module Common
          using Receiptisan::Util::WarekiExtension

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
                  text:   date.to_wareki(zenkaku: true)
                )
              end
            end
          end
          WarekiMonth = Struct.new(:gengou, :year, :month, :text, keyword_init: true) do
            class << self
              # @param month [::Month]
              def from(month)
                gengou = WarekiGengou.from(::Date.new(month.year, month.month, month.length))

                new(
                  gengou: gengou,
                  year:   month.year - gengou.base_year,
                  month:  month.month,
                  text:   month.to_wareki(zenkaku: true)
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
            :classification,
            :shoubyoumeis,
            :tekiyou,
            :ryouyou_no_kyuufu,
            :tensuu_shuukei,
            :nyuuin_date,
            :nyuuinryou_abbrev_labels,
            :byoushou_types,
            :kijun_marks,
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

          class ByoushouType < CodedItemWithShortName
            class << self
              # @param byoushou_type [Model::ReceiptComputer::DigitalizedReceipt::ByoushouType]
              # @return [self]
              def from(byoushou_type)
                new(
                  code:       byoushou_type.code,
                  name:       byoushou_type.name,
                  short_name: byoushou_type.short_name
                )
              end
            end
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

          AppliedHokenList = Struct.new(:iryou_hoken, :kouhi_futan_iryous, :main, keyword_init: true)
          HokenWithOrder   = Struct.new(:order, :hoken, keyword_init: true)
          IryouHoken       = Struct.new(
            :hokenja_bangou,
            :kigou,
            :bangou,
            :edaban,
            :kyuufu_wariai,
            :teishotoku_type,
            keyword_init: true
          ) do
            class << self
              # @param iryou_hoken [Model::ReceiptComputer::DigitalizedReceipt::Receipt::IryouHoken]
              # @return [self]
              def from(iryou_hoken)
                new(
                  hokenja_bangou:  iryou_hoken.hokenja_bangou,
                  kigou:           iryou_hoken.kigou,
                  bangou:          iryou_hoken.bangou,
                  edaban:          iryou_hoken.edaban,
                  kyuufu_wariai:   iryou_hoken.kyuufu_wariai,
                  teishotoku_type: iryou_hoken.teishotoku_type&.then do | teishotoku_type |
                    TeishotokuType.from(teishotoku_type)
                  end
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
          class TeishotokuType < CodedItemWithShortName
            class << self
              # @param teishotoku_type [Model::ReceiptComputer::DigitalizedReceipt::Receipt::TeishotokuType]
              def from(teishotoku_type)
                new(
                  code:       teishotoku_type.code,
                  name:       teishotoku_type.name,
                  short_name: teishotoku_type.short_name
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
                  is_prefix: master_shuushokugo.prefix?
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
          # 点数欄「97食事・生活」の「基準」および「基準(生)」に埋め込む、
          # 算定食事・生活療養費のローマ数字による略号
          ShokujiSeikatsuKijunMarks = Struct.new(:shokuji, :seikatsu, keyword_init: true)

          # 摘要欄

          Tekiyou                   = Struct.new(:shinryou_shikibetsu_sections, keyword_init: true)
          ShinryouShikibetsuSection = Struct.new(:shinryou_shikibetsu, :ichiren_units, keyword_init: true)
          class ShinryouShikibetsu < CodedItem
            extend CodedItemFactory
          end
          IchirenUnit    = Struct.new(:futan_kubun, :santei_units, keyword_init: true)
          SanteiUnit     = Struct.new(:tensuu, :kaisuu, :items, keyword_init: true)

          Cost = Struct.new(
            :type,
            :master,
            :text,
            :shiyouryou,
            :unit,
            :tensuu,
            :kaisuu,
            keyword_init: true
          )

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

          TekiyouText = Struct.new(
            :product_name,
            :master_name,
            :unit_price,
            :shiyouryou,
            keyword_init: true
          )

          # 療養の給付欄

          RyouyouNoKyuufuList = Struct.new(:iryou_hoken, :kouhi_futan_iryous, keyword_init: true)
          RyouyouNoKyuufu     = Struct.new(
            :goukei_tensuu,
            :shinryou_jitsunissuu,
            :ichibu_futankin,
            :kyuufu_taishou_ichibu_futankin,
            :shokuji_seikatsu_ryouyou_kaisuu,
            :shokuji_seikatsu_ryouyou_goukei_kingaku,
            :shokuji_seikatsu_ryouyou_hyoujun_futangaku,
            keyword_init: true
          )
        end
        # rubocop:enable Metrics/ModuleLength
      end
    end
  end
end
