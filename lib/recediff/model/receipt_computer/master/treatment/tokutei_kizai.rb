# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class Master
        module Treatment
          # 特定器材
          class TokuteiKizai
            # @param code [TokuteiKizaiCode]
            # @param name [String]
            # @param name_kana [String]
            # @param unit [Unit]
            # @param price_type [PriceType]
            # @param price [Numeric]
            # @param full_name [String]
            def initialize(
              code:,
              name:,
              name_kana:,
              unit:,
              price_type:,
              price:,
              full_name:
            )
              @code       = code
              @name       = name
              @name_kana  = name_kana
              @unit       = unit
              @price_type = price_type
              @price      = price
              @full_name  = full_name
            end

            # @!attribute [r] code
            #   @return [TokuteiKizaiCode]
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

            # 特定器材コード
            class Code
              include MasterItemCodeInterface

              class << self
                def __name
                  '特定器材'
                end
              end
            end

            # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators
            module Columns
              C_変更区分                        = 0
              C_マスター種別                    = 1
              C_コード                          = 2
              C_特定器材名・規格名_漢字有効桁数 = 3
              C_特定器材名・規格名_漢字名称     = 4
              C_特定器材名・規格名_カナ有効桁数 = 5
              C_特定器材名・規格名_カナ名称     = 6
              C_単位_コード                     = 7
              C_単位_漢字有効桁数               = 8
              C_単位_漢字名称                   = 9
              C_金額種別                        = 10
              C_新又は現金額                    = 11
              C_予備_1                          = 12
              C_年齢加算区分                    = 13
              C_上下限年齢_下限年齢             = 14
              C_上下限年齢_上限年齢             = 15
              C_旧金額種別                      = 16
              C_旧金額                          = 17
              C_漢字名称変更区分                = 18
              C_カナ名称変更区分                = 19
              C_酸素等区分                      = 20
              C_特定器材種別                    = 21
              C_上限価格                        = 22
              C_上限点数                        = 23
              C_予備_2                          = 24
              C_公表順序番号                    = 25
              C_廃止・新設関連                  = 26
              C_変更年月日                      = 27
              C_経過措置年月日                  = 28
              C_廃止年月日                      = 29
              C_告示番号_別表番号               = 30
              C_告示番号_区分番号               = 31
              C_DPC適用区分                     = 32
              C_予備_3                          = 33
              C_予備_4                          = 34
              C_予備_5                          = 35
              C_基本漢字名称                    = 36
            end
            # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators
          end
        end
      end
    end
  end
end
