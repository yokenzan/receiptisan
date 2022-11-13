# frozen_string_literal: true

module Recediff
  module Output
    module Preview
      class Parameter
        # 汎用

        CodedItem              = Struct.new(:code, :name, keyword_init: true)
        CodedItemWithShortName = Struct.new(:code, :name, :short_name, keyword_init: true)

        # 年月日

        Month        = Struct.new(:year, :month, :wareki, keyword_init: true)
        WarekiMonth  = Struct.new(:gengou, :year, :month, keyword_init: true)
        Date         = Struct.new(:year, :month, :day, :wareki, keyword_init: true)
        WarekiDate   = Struct.new(:gengou, :year, :month, :day, keyword_init: true)
        WarekiGengou = Struct.new(:code, :name, :short_name, :alphabet, :base_year, keyword_init: true)

        # 電子レセプトファイル(請求書)レベル

        DigitalizedReceipt = Struct.new(:seikyuu_ym, :audit_payer, :hospital, :prefecture, :receipts, keyword_init: true) do
          def add_receipt(parameterized_receipt)
            receipts << parameterized_receipt
          end
        end
        Hospital           = Struct.new(:code, :name, :tel, :address, keyword_init: true)

        class AuditPayer < CodedItemWithShortName; end

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
          keyword_init: true
        )
        Patient = Struct.new(:id, :name, :name_kana, :sex, :birth_date, keyword_init: true)
        Type    = Struct.new(
          :tensuu_hyou_type,
          :main_hoken_type,
          :hoken_multiple_type,
          :patient_age_type,
          keyword_init: true
        )
        class TensuuHyouType    < CodedItem; end
        class MainHokenType     < CodedItem; end
        class HokenMultipleType < CodedItem; end
        class PatientAgeType    < CodedItem; end
        class TokkiJikou        < CodedItem; end
        class Prefecture        < CodedItemWithShortName; end
        class Sex               < CodedItem; end

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
        )
        KouhiFutanIryou  = Struct.new(:futansha_bangou, :jukyuusha_bangou, keyword_init: true)

        # 傷病名

        GroupedShoubyoumeiList = Struct.new(:start_date, :tenki, :is_main, :shoubyoumeis, keyword_init: true)
        Shoubyoumei            = Struct.new(
          :master_shoubyoumei,
          :master_shuushokugos,
          :text,
          :is_main,
          :is_worpro,
          :comment,
          keyword_init: true
        )
        MasterShoubyoumei      = Struct.new(:code, :name, keyword_init: true)
        MasterShuushokugo      = Struct.new(:code, :name, :is_prefix, keyword_init: true)

        # 摘要欄

        Tekiyou                   = Struct.new(:shinryou_shikibetsu_sections, keyword_init: true)
        ShinryouShikibetsuSection = Struct.new(:shinryou_shikibetsu, :ichiren_units, keyword_init: true)
      end
    end
  end
end
