# frozen_string_literal: true

require_relative 'master/versions'
require_relative 'master/master_item_code_interface'
require_relative 'master/treatment'
require_relative 'master/diagnosis'
require_relative 'master/resource_resolver'
require_relative 'master/loader'

module Receiptisan
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

        # @param code [MasterItemCodeInterface]
        #
        # @overload find_by_code(shinryou_koui_code)
        #   診療行為を取得する
        #   @param shinryou_koui_code [Treatment::ShinryouKoui::Code]
        #   @return [Treatment::ShinryouKoui, nil]
        # @overload find_by_code(iyakuhin_code)
        #   医薬品を取得する
        #   @param iyakuhin_code [Treatment::Iyakuhin::Code]
        #   @return [Treatment::Iyakuhin, nil]
        # @overload find_by_code(tokutei_kizai_code)
        #   特定器材を取得する
        #   @param tokutei_kizai_code [Treatment::TokuteiKizai::Code]
        #   @return [Treatment::TokuteiKizai, nil]
        # @overload find_by_code(comment_code)
        #   コメントを取得する
        #   @param comment_code [Treatment::Comment::Code]
        #   @return [Treatment::Comment, nil]
        # @overload find_by_code(shoubyoumei_code)
        #   傷病名を取得する
        #   @param shoubyoumei_code [Diagnosis::Shoubyoumei::Code]
        #   @return [Diagnosis::Shoubyoumei, nil]
        # @overload find_by_code(shuushokugo_code)
        #   修飾語を取得する
        #   @param shuushokugo_code [Diagnosis::Shuushokugo::Code]
        #   @return [Diagnosis::Shuushokugo, nil]
        def find_by_code(code)
          master =
            case code
            when Treatment::ShinryouKoui::Code
              shinryou_koui
            when Treatment::Iyakuhin::Code
              iyakuhin
            when Treatment::TokuteiKizai::Code
              tokutei_kizai
            when Treatment::Comment::Code
              comment
            when Diagnosis::Shoubyoumei::Code
              shoubyoumei
            when Diagnosis::Shuushokugo::Code
              shuushokugo
            end

          master[code.value] ||
            raise(MasterItemNotFoundError, "#{code.name} #{code.value} is not found")
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
        #   @return [Hash<String, Diagnosis::Shoubyoumei>]
        # @!attribute [r] shuushokugo
        #   @return [Hash<String, Diagnosis::Shuushokugo>]
        attr_reader :shinryou_koui, :iyakuhin, :tokutei_kizai, :comment, :shoubyoumei, :shuushokugo

        class MasterItemNotFoundError < StandardError
        end

        # 単位コード
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
            # @param code [Integer, String, Symbol]
            # @return [self, nil]
            def find_by_code(code)
              return if code.nil?

              @units[code.to_s.intern]
            end
          end

          @units = {
            '1':   new(code: 1,   name: '分'),
            '2':   new(code: 2,   name: '回'),
            '3':   new(code: 3,   name: '種'),
            '4':   new(code: 4,   name: '箱'),
            '5':   new(code: 5,   name: '巻'),
            '6':   new(code: 6,   name: '枚'),
            '7':   new(code: 7,   name: '本'),
            '8':   new(code: 8,   name: '組'),
            '9':   new(code: 9,   name: 'セット'),
            '10':  new(code: 10,  name: '個'),
            '11':  new(code: 11,  name: '裂'),
            '12':  new(code: 12,  name: '方向'),
            '13':  new(code: 13,  name: 'トローチ'),
            '14':  new(code: 14,  name: 'アンプル'),
            '15':  new(code: 15,  name: 'カプセル'),
            '16':  new(code: 16,  name: '錠'),
            '17':  new(code: 17,  name: '丸'),
            '18':  new(code: 18,  name: '包'),
            '19':  new(code: 19,  name: '瓶'),
            '20':  new(code: 20,  name: '袋'),
            '21':  new(code: 21,  name: '瓶（袋）'),
            '22':  new(code: 22,  name: '管'),
            '23':  new(code: 23,  name: 'シリンジ'),
            '24':  new(code: 24,  name: '回分'),
            '25':  new(code: 25,  name: 'テスト分'),
            '26':  new(code: 26,  name: 'ガラス筒'),
            '27':  new(code: 27,  name: '桿錠'),
            '28':  new(code: 28,  name: '単位'),
            '29':  new(code: 29,  name: '万単位'),
            '30':  new(code: 30,  name: 'フィート'),
            '31':  new(code: 31,  name: '滴'),
            '32':  new(code: 32,  name: '㎎'),
            '33':  new(code: 33,  name: 'ｇ'),
            '34':  new(code: 34,  name: '㎏'),
            '35':  new(code: 35,  name: '㏄'),
            '36':  new(code: 36,  name: '㎖'),
            '37':  new(code: 37,  name: 'ℓ'),
            '38':  new(code: 38,  name: '㎖Ｖ'),
            '39':  new(code: 39,  name: 'バイアル'),
            '40':  new(code: 40,  name: '㎝'),
            '41':  new(code: 41,  name: '㎠'),
            '42':  new(code: 42,  name: 'ｍ'),
            '43':  new(code: 43,  name: 'μＣｉ'),
            '44':  new(code: 44,  name: 'ｍＣｉ'),
            '45':  new(code: 45,  name: '㎍'),
            '46':  new(code: 46,  name: '管（瓶）'),
            '47':  new(code: 47,  name: '筒'),
            '48':  new(code: 48,  name: 'ＧＢｑ'),
            '49':  new(code: 49,  name: 'ＭＢｑ'),
            '50':  new(code: 50,  name: 'ＫＢｑ'),
            '51':  new(code: 51,  name: 'キット'),
            '52':  new(code: 52,  name: '国際単位'),
            '53':  new(code: 53,  name: '患者当り'),
            '54':  new(code: 54,  name: '気圧'),
            '55':  new(code: 55,  name: '缶'),
            '56':  new(code: 56,  name: '手術当り'),
            '57':  new(code: 57,  name: '容器'),
            '58':  new(code: 58,  name: '㎖（ｇ）'),
            '59':  new(code: 59,  name: 'ブリスター'),
            '60':  new(code: 60,  name: 'シート'),
            '61':  new(code: 61,  name: 'カセット'),
            '101': new(code: 101, name: '分画'),
            '102': new(code: 102, name: '染色'),
            '103': new(code: 103, name: '種類'),
            '104': new(code: 104, name: '株'),
            '105': new(code: 105, name: '菌株'),
            '106': new(code: 106, name: '照射'),
            '107': new(code: 107, name: '臓器'),
            '108': new(code: 108, name: '件'),
            '109': new(code: 109, name: '部位'),
            '110': new(code: 110, name: '肢'),
            '111': new(code: 111, name: '局所'),
            '112': new(code: 112, name: '種目'),
            '113': new(code: 113, name: 'スキャン'),
            '114': new(code: 114, name: 'コマ'),
            '115': new(code: 115, name: '処理'),
            '116': new(code: 116, name: '指'),
            '117': new(code: 117, name: '歯'),
            '118': new(code: 118, name: '面'),
            '119': new(code: 119, name: '側'),
            '120': new(code: 120, name: '個所'),
            '121': new(code: 121, name: '日'),
            '122': new(code: 122, name: '椎間'),
            '123': new(code: 123, name: '筋'),
            '124': new(code: 124, name: '菌種'),
            '125': new(code: 125, name: '項目'),
            '126': new(code: 126, name: '箇所'),
            '127': new(code: 127, name: '椎弓'),
            '128': new(code: 128, name: '食'),
            '129': new(code: 129, name: '根管'),
            '130': new(code: 130, name: '３分の１顎'),
            '131': new(code: 131, name: '月'),
            '132': new(code: 132, name: '入院初日'),
            '133': new(code: 133, name: '入院中'),
            '134': new(code: 134, name: '退院時'),
            '135': new(code: 135, name: '初回'),
            '136': new(code: 136, name: '口腔'),
            '137': new(code: 137, name: '顎'),
            '138': new(code: 138, name: '週'),
            '139': new(code: 139, name: '窩洞'),
            '140': new(code: 140, name: '神経'),
            '141': new(code: 141, name: '一連'),
            '142': new(code: 142, name: '２週'),
            '143': new(code: 143, name: '２月'),
            '144': new(code: 144, name: '３月'),
            '145': new(code: 145, name: '４月'),
            '146': new(code: 146, name: '６月'),
            '147': new(code: 147, name: '１２月'),
            '148': new(code: 148, name: '５年'),
            '149': new(code: 149, name: '妊娠中'),
            '150': new(code: 150, name: '検査当り'),
            '151': new(code: 151, name: '１疾患当り'),
            '153': new(code: 153, name: '装置'),
            '154': new(code: 154, name: '１歯１回'),
            '155': new(code: 155, name: '１口腔１回'),
            '156': new(code: 156, name: '床'),
            '157': new(code: 157, name: '１顎１回'),
            '158': new(code: 158, name: '椎体'),
            '159': new(code: 159, name: '初診時'),
            '160': new(code: 160, name: '１分娩当り'),
            '161': new(code: 161, name: '２年'),
          }
          @units.each(&:freeze).freeze
        end
      end
    end
  end
end
