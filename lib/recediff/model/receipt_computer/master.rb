# frozen_string_literal: true

require_relative 'master/version'
require_relative 'master/treatment'
require_relative 'master/diagnose'
require_relative 'master/loader'

module Recediff
  module Model
    module ReceiptComputer
      # 診療報酬マスタ
      class Master
        def initialize(
          shinryou_koui:,
          iyakuhin:,
          tokutei_kizai:,
          comment:,
          shoubyoumei:,
          shuushokugo:
        )
          @shinryou_koui = shinryou_koui
          @iyakuhin      = iyakuhin
          @tokutei_kizai = tokutei_kizai
          @comment       = comment
          @shoubyoumei   = shoubyoumei
          @shuushokugo   = shuushokugo
        end

        # @!attribute [r] shinryou_koui
        #   @return [Hash<String, Treatment::ShinryouKoui>]
        # @!attribute [r] iyakuhin
        #   @return [Hash<String, Treatment::Iyakuhin>]
        # @!attribute [r] tokutei_kizai
        #   @return [Hash<String, Treatment::TokuteiKizai>]
        # @!attribute [r] comment
        #   @return [Hash<String, Treatment::Comment>]
        # @!attribute [r] shoubyoumei
        #   @return [Hash<String, Diagnose::Shoubyoumei>]
        # @!attribute [r] shuushokugo
        #   @return [Hash<String, Diagnose::Shuushokugo>]
        attr_reader :shinryou_koui, :iyakuhin, :tokutei_kizai, :comment, :shoubyoumei, :shuushokugo

        class Unit
          # @param code [String]
          # @param name [String]
          def initialize(code:, name:)
            @code = code
            @name = name
          end

          # @!attribute [r] code
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          attr_reader :code, :name

          class << self
            # @param code [String]
            # @return [self, nil]
            def find_by_code(code)
              @units.find { | unit | unit.code == code.to_i }
            end
          end

          @units = [
            new(code: 1,   name: '分'),
            new(code: 2,   name: '回'),
            new(code: 3,   name: '種'),
            new(code: 4,   name: '箱'),
            new(code: 5,   name: '巻'),
            new(code: 6,   name: '枚'),
            new(code: 7,   name: '本'),
            new(code: 8,   name: '組'),
            new(code: 9,   name: 'セット'),
            new(code: 10,  name: '個'),
            new(code: 11,  name: '裂'),
            new(code: 12,  name: '方向'),
            new(code: 13,  name: 'トローチ'),
            new(code: 14,  name: 'アンプル'),
            new(code: 15,  name: 'カプセル'),
            new(code: 16,  name: '錠'),
            new(code: 17,  name: '丸'),
            new(code: 18,  name: '包'),
            new(code: 19,  name: '瓶'),
            new(code: 20,  name: '袋'),
            new(code: 21,  name: '瓶（袋）'),
            new(code: 22,  name: '管'),
            new(code: 23,  name: 'シリンジ'),
            new(code: 24,  name: '回分'),
            new(code: 25,  name: 'テスト分'),
            new(code: 26,  name: 'ガラス筒'),
            new(code: 27,  name: '桿錠'),
            new(code: 28,  name: '単位'),
            new(code: 29,  name: '万単位'),
            new(code: 30,  name: 'フィート'),
            new(code: 31,  name: '滴'),
            new(code: 32,  name: 'ｍｇ'),
            new(code: 33,  name: 'ｇ'),
            new(code: 34,  name: 'Ｋｇ'),
            new(code: 35,  name: 'ｃｃ'),
            new(code: 36,  name: 'ｍＬ'),
            new(code: 37,  name: 'Ｌ'),
            new(code: 38,  name: 'ｍＬＶ'),
            new(code: 39,  name: 'バイアル'),
            new(code: 40,  name: 'ｃｍ'),
            new(code: 41,  name: 'ｃｍ２'),
            new(code: 42,  name: 'ｍ'),
            new(code: 43,  name: 'μＣｉ'),
            new(code: 44,  name: 'ｍＣｉ'),
            new(code: 45,  name: 'μｇ'),
            new(code: 46,  name: '管（瓶）'),
            new(code: 47,  name: '筒'),
            new(code: 48,  name: 'ＧＢｑ'),
            new(code: 49,  name: 'ＭＢｑ'),
            new(code: 50,  name: 'ＫＢｑ'),
            new(code: 51,  name: 'キット'),
            new(code: 52,  name: '国際単位'),
            new(code: 53,  name: '患者当り'),
            new(code: 54,  name: '気圧'),
            new(code: 55,  name: '缶'),
            new(code: 56,  name: '手術当り'),
            new(code: 57,  name: '容器'),
            new(code: 58,  name: 'ｍＬ（ｇ）'),
            new(code: 59,  name: 'ブリスター'),
            new(code: 60,  name: 'シート'),
            new(code: 61,  name: 'カセット'),
            new(code: 101, name: '分画'),
            new(code: 102, name: '染色'),
            new(code: 103, name: '種類'),
            new(code: 104, name: '株'),
            new(code: 105, name: '菌株'),
            new(code: 106, name: '照射'),
            new(code: 107, name: '臓器'),
            new(code: 108, name: '件'),
            new(code: 109, name: '部位'),
            new(code: 110, name: '肢'),
            new(code: 111, name: '局所'),
            new(code: 112, name: '種目'),
            new(code: 113, name: 'スキャン'),
            new(code: 114, name: 'コマ'),
            new(code: 115, name: '処理'),
            new(code: 116, name: '指'),
            new(code: 117, name: '歯'),
            new(code: 118, name: '面'),
            new(code: 119, name: '側'),
            new(code: 120, name: '個所'),
            new(code: 121, name: '日'),
            new(code: 122, name: '椎間'),
            new(code: 123, name: '筋'),
            new(code: 124, name: '菌種'),
            new(code: 125, name: '項目'),
            new(code: 126, name: '箇所'),
            new(code: 127, name: '椎弓'),
            new(code: 128, name: '食'),
            new(code: 129, name: '根管'),
            new(code: 130, name: '３分の１顎'),
            new(code: 131, name: '月'),
            new(code: 132, name: '入院初日'),
            new(code: 133, name: '入院中'),
            new(code: 134, name: '退院時'),
            new(code: 135, name: '初回'),
            new(code: 136, name: '口腔'),
            new(code: 137, name: '顎'),
            new(code: 138, name: '週'),
            new(code: 139, name: '窩洞'),
            new(code: 140, name: '神経'),
            new(code: 141, name: '一連'),
            new(code: 142, name: '２週'),
            new(code: 143, name: '２月'),
            new(code: 144, name: '３月'),
            new(code: 145, name: '４月'),
            new(code: 146, name: '６月'),
            new(code: 147, name: '１２月'),
            new(code: 148, name: '５年'),
            new(code: 149, name: '妊娠中'),
            new(code: 150, name: '検査当り'),
            new(code: 151, name: '１疾患当り'),
            new(code: 153, name: '装置'),
            new(code: 154, name: '１歯１回'),
            new(code: 155, name: '１口腔１回'),
            new(code: 156, name: '床'),
            new(code: 157, name: '１顎１回'),
            new(code: 158, name: '椎体'),
            new(code: 159, name: '初診時'),
            new(code: 160, name: '１分娩当り'),
            new(code: 161, name: '２年'),
          ]
        end
      end
    end
  end
end
