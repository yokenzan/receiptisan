# frozen_string_literal: true

module Recediff
  module Output
    module Preview
      class Parameter
        # 汎用

        CodedItem              = Struct.new(:code, :name)
        CodedItemWithShortName = Struct.new(:code, :name, :short_name)

        # 年月日

        Month        = Struct.new(:year, :month, :wareki)
        WarekiMonth  = Struct.new(:gengou, :year, :month)
        Date         = Struct.new(:year, :month, :day, :wareki)
        WarekiDate   = Struct.new(:gengou, :year, :month, :day)
        WarekiGengou = Struct.new(:code, :name, :short_name, :alphabet, :base_year)

        # 電子レセプトファイル(請求書)レベル

        DigitalizedReceipt = Struct.new(:seikyuu_ym, :audit_payer, :hospital, :prefecture, :receipts) do
          def add_receipt(parameterized_receipt)
            receipts << parameterized_receipt
          end
        end
        Hospital           = Struct.new(:code, :name, :tel, :address)

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
          :ryouyou_no_kyuufu
        )
        Patient = Struct.new(:id, :name, :name_kana, :sex, :birth_date)
        Type    = Struct.new(
          :tensuu_hyou_type,
          :main_hoken_type,
          :hoken_multiple_type,
          :patient_age_type
        )
        class TensuuHyouType    < CodedItem; end
        class MainHokenType     < CodedItem; end
        class HokenMultipleType < CodedItem; end
        class PatientAgeType    < CodedItem; end
        class TokkiJikou        < CodedItem; end
        class Prefecture        < CodedItemWithShortName; end
        class Sex               < CodedItem; end

        # 保険

        AppliedHokenList = Struct.new(:iryou_hoken, :kouhi_futan_iryous)
        IryouHoken       = Struct.new(
          :hokenja_bangou,
          :kigou,
          :bangou,
          :edaban,
          :kyuufu_wariai,
          :teishotoku_kubun
        )
        KouhiFutanIryou  = Struct.new(:futansha_bangou, :jukyuusha_bangou)

        # 傷病名

        GroupedShoubyoumeiList = Struct.new(:start_date, :tenki, :is_main, :shoubyoumeis)
        Shoubyoumei            = Struct.new(
          :master_shoubyoumei,
          :master_shuushokugos,
          :text,
          :is_main,
          :is_worpro,
          :comment
        )
        MasterShoubyoumei      = Struct.new(:code, :name)
        MasterShuushokugo      = Struct.new(:code, :name, :is_prefix)

        # 摘要欄

        Tekiyou                   = Struct.new(:shinryou_shikibetsu_sections)
        ShinryouShikibetsuSection = Struct.new(:shinryou_shikibetsu, :ichiren_units)
      end
    end
  end
end
