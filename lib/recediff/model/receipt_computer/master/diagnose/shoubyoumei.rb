# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class Master
        module Diagnose
          # 傷病名
          class Shoubyoumei
            # @param code [String]
            # @param full_name [String]
            # @param name [String]
            # @param name_kana [String]
            def initialize(code:, full_name:, name:, name_kana:)
              @code      = code
              @full_name = full_name
              @name      = name
              @name_kana = name_kana
            end

            # @!attribute [r] code
            #   @return [String]
            attr_reader :code
            # @!attribute [r] full_name
            #   @return [String]
            attr_reader :full_name
            # @!attribute [r] name
            #   @return [String]
            attr_reader :name
            # @!attribute [r] name_kana
            #   @return [String]
            attr_reader :name_kana

            module Columns
              C_変更区分                           = 0
              C_マスター種別                       = 1
              C_コード                             = 2
              C_移行先コード                       = 3
              C_傷病名_基本名称桁数                = 4
              C_傷病名_基本名称                    = 5
              C_傷病名_省略名称桁数                = 6
              C_傷病名_省略名称                    = 7
              C_傷病名_カナ名称桁数                = 8
              C_傷病名_カナ名称                    = 9
              C_病名管理番号                       = 10
              C_採択区分                           = 11
              C_病名交換用コード                   = 12
              C_ＩＣＤ－１０－１                   = 13
              C_ＩＣＤ－１０－２                   = 14
              C_ＩＣＤ－１０－１_２０１３          = 15
              C_ＩＣＤ－１０－２_２０１３          = 16
              C_予備_1                             = 17
              C_単独使用禁止区分                   = 18
              C_保険請求外区分                     = 19
              C_特定疾患等対象区分                 = 20
              C_収載年月日                         = 21
              C_変更年月日                         = 22
              C_廃止年月日                         = 23
              C_傷病名_基本名称_変更情報           = 24
              C_傷病名_省略名称_変更情報           = 25
              C_傷病名_カナ名称_変更情報           = 26
              C_採択区分_変更情報                  = 27
              C_病名交換用コード_変更情報          = 28
              C_ＩＣＤ－１０－１_変更情報          = 29
              C_ＩＣＤ－１０－２_変更情報          = 30
              C_歯科傷病名省略名称_変更情報        = 31
              C_難病外来対象区分_変更情報          = 32
              C_歯科特定疾患対象区分_変更情報      = 33
              C_単独使用禁止区分_変更情報          = 34
              C_保険請求外区分_変更情報            = 35
              C_特定疾患等対象区分_変更情報        = 36
              C_移行先病名管理番号                 = 37
              C_歯科傷病名省略名称                 = 38
              C_予備_2                             = 39
              C_予備_3                             = 40
              C_歯科傷病名省略名称桁               = 41
              C_難病外来対象区分                   = 42
              C_歯科特定疾患対象区分               = 43
              C_ＩＣＤ－１０－１_２０１３_変更情報 = 44
              C_ＩＣＤ－１０－２_２０１３_変更情報 = 45
            end
          end
        end
      end
    end
  end
end
