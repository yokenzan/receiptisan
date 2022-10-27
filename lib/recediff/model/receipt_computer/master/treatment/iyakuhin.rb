# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class Master
        module Treatment
          # 医薬品
          class Iyakuhin
            # @param code [IyakuhinCode]
            # @param name [String]
            # @param name_kana [String]
            # @param unit [Unit]
            # @param price_type [PriceType]
            # @param price [Numeric]
            # @param chuusha_youryou [Numeric]
            # @param dosage_form [DosageFormType]
            # @param full_name [String]
            def initialize(
              code:,
              name:,
              name_kana:,
              unit:,
              price_type:,
              price:,
              chuusha_youryou:,
              dosage_form:,
              full_name:
            )
              @code            = code
              @name            = name
              @name_kana       = name_kana
              @unit            = unit
              @price_type      = price_type
              @price           = price
              @chuusha_youryou = chuusha_youryou
              @dosage_form     = dosage_form
              @full_name       = full_name
            end

            # @!attribute [r] code
            #   @return [IyakuhinCode]
            attr_reader :code
            # @!attribute [r] name
            #   @return [String]
            attr_reader :name
            # @!attribute [r] name_kana
            #   @return [String]
            attr_reader :name_kana
            # @!attribute [r] unit
            #   @return [Unit]
            attr_reader :unit
            # @!attribute [r] price
            #   @return [Numeric]
            attr_reader :price
            # @!attribute [r] full_name
            #   @return [String]
            attr_reader :full_name

            # 剤形
            class DosageFormType
              def initialize(code)
                @code = code
              end
            end

            module Columns
              C_変更区分                                     = 0
              C_マスター種別                                 = 1
              C_コード                                       = 2
              C_医薬品名・規格名_漢字有効桁数                = 3
              C_医薬品名・規格名_漢字名称                    = 4
              C_医薬品名・規格名_カナ有効桁数                = 5
              C_医薬品名・規格名_カナ名称                    = 6
              C_単位_コード                                  = 7
              C_単位_漢字有効桁数                            = 8
              C_単位_漢字名称                                = 9
              C_金額種別                                     = 10
              C_新又は現金額                                 = 11
              C_麻薬・毒薬・覚醒剤原料・向精神薬             = 12
              C_予備_1                                       = 13
              C_神経破壊剤                                   = 14
              C_生物学的製剤                                 = 15
              C_後発品                                       = 16
              C_予備_2                                       = 17
              C_歯科特定薬剤                                 = 18
              C_造影（補助）剤                               = 19
              C_注射容量                                     = 20
              C_収載方式等識別                               = 21
              C_商品名等関連                                 = 22
              C_旧金額種別                                   = 23
              C_旧金額                                       = 24
              C_漢字名称変更区分                             = 25
              C_カナ名称変更区分                             = 26
              C_剤形                                         = 27
              C_予備_3                                       = 28
              C_変更年月日                                   = 29
              C_廃止年月日                                   = 30
              C_薬価基準収載医薬品コード                     = 31
              C_公表順序番号                                 = 32
              C_経過措置年月日又は商品名医薬品コード使用期限 = 33
              C_基本漢字名称                                 = 34
            end
          end
        end
      end
    end
  end
end
