# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class Master
        module Diagnose
          # 修飾語
          class Shuushokugo
            extend Forwardable

            # @param code [ShoubyoumeiCode]
            # @param name [String]
            # @param name_kana [String]
            def initialize(code:, name:, name_kana:, category:)
              @code      = code
              @name      = name
              @name_kana = name_kana
              @category  = category
            end

            # @!attribute [r] code
            #   @return [ShoubyoumeiCode]
            # @!attribute [r] name
            #   @return [String]
            # @!attribute [r] name_kana
            #   @return [String]
            attr_reader :code, :name, :name_kana

            def_delegators :@category, :prefix?, :suffix?

            # 修飾語コード
            class Code
              include MasterItemCodeInterface

              class << self
                def __name
                  '修飾語'
                end

                def __digit_length
                  4
                end
              end

              def __to_code
                '%04d' % @code.to_s.to_i
              end
            end

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

            class Category
              # @param code [Symbol]
              # @param name [String]
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              # 接尾語？
              def suffix?
                code == :'8'
              end

              # 接頭語？
              def prefix?
                !suffix?
              end

              # @!attribute [r] code
              #   @return [Symbol]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name

              @types = {
                '1': new(code: :'1', name: '部位（頭部、頸部等）'),
                '2': new(code: :'2', name: '位置（左、右等）'),
                '3': new(code: :'3', name: '病因（外傷性、感染症等）'),
                '4': new(code: :'4', name: '経過表現（急性、慢性等）'),
                '5': new(code: :'5', name: '状態表現（悪性、良性等）'),
                '6': new(code: :'6', name: '患者帰属（胎児、老人性等）'),
                '7': new(code: :'7', name: 'その他（高度、生理的等）'),
                '8': new(code: :'8', name: '接尾語'),
                '9': new(code: :'9', name: '歯科用（未収録）'),
              }

              class << self
                # @param code [String, Integer]
                # @return [self, nil]
                def find_by_code(code)
                  @types[code.to_s.intern]
                end
              end
            end
          end
        end
      end
    end
  end
end
