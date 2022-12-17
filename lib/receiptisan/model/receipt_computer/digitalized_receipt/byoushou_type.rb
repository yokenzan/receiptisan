# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 病床区分(手引きでは『病棟区分』)
        #
        # 手引き別表7 病棟区分コード
        #
        # > [診療報酬請求書等の記載要領](https://www.mhlw.go.jp/content/12404000/000984055.pdf#page=12)
        # >
        # > (10) 「区分」欄について
        # >
        # > 当該患者が入院している病院又は病棟の種類に応じ、該当する文字を○で囲むこと。また、月の途中において病棟を移った場合は、そのすべてに○を付すこと。
        # > なお、電子計算機の場合は、コードと名称又は次の略称を記載することとしても差し支えないこと。
        # > ０１精神（精神病棟）、０２結核（結核病棟）、０７療養（療養病棟）
        class ByoushouType
          BYOUSHOU_TYPE_SEISHIN = :'01'
          BYOUSHOU_TYPE_KEKKAKU = :'02'
          BYOUSHOU_TYPE_RYOUYOU = :'07'

          def initialize(code:, name:, short_name:)
            @code       = code
            @name       = name
            @short_name = short_name
          end

          # @!attribute [r] code
          #   @return [Symbol]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] short_name
          #   @return [String]
          attr_reader :code, :name, :short_name

          @list = {
            BYOUSHOU_TYPE_SEISHIN => new(code: BYOUSHOU_TYPE_SEISHIN, name: '精神病棟', short_name: '精神'),
            BYOUSHOU_TYPE_KEKKAKU => new(code: BYOUSHOU_TYPE_KEKKAKU, name: '結核病棟', short_name: '結核'),
            BYOUSHOU_TYPE_RYOUYOU => new(code: BYOUSHOU_TYPE_RYOUYOU, name: '療養病棟', short_name: '療養'),
          }
          @list.each(&:freeze).freeze

          class << self
            # @param code [String, Integer]
            # @return [self, nil]
            def find_by_code(code)
              @list[('%02d' % code.to_s.to_i).intern]
            end
          end
        end
      end
    end
  end
end
