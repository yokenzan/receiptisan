# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class Master
        module Diagnose
          # 修飾語
          class Shuushokugo
            def initialize(code:, name:, name_kana:)
              @code      = code
              @name      = name
              @name_kana = name_kana
            end

            attr_reader :code, :name, :name_kana

            module Columns
              C_変更区分           = 0
              C_マスター種別       = 1
              C_コード             = 2
              C_予備_1             = 3
              C_予備_2             = 4
              C_修飾語名称桁数     = 5
              C_修飾語名称         = 6
              C_予備_3             = 7
              C_修飾語カナ名称桁数 = 8
              C_修飾語カナ名称     = 9
              C_予備_4             = 10
              C_名称_変更情報      = 11
              C_カナ名称_変更情報  = 12
              C_収載年月日         = 13
              C_変更年月日         = 14
              C_廃止年月日         = 15
              C_修飾語管理番号     = 16
              C_修飾語交換用コード = 17
              C_修飾語区分         = 18
            end
          end
        end
      end
    end
  end
end
