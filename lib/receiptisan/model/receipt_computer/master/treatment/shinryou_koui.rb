# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        module Treatment
          # 診療行為
          class ShinryouKoui
            def initialize(
              code:,
              name:,
              name_kana:,
              unit:,
              point_type:,
              point:,
              full_name:
            )
              @code       = code
              @name       = name
              @name_kana  = name_kana
              @unit       = unit
              @point_type = point_type
              @point      = point
              @full_name  = full_name
            end

            # @!attribute [r] code
            #   @return [ShinryouKouiCode]
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
            # @!attribute [r] point_type
            #   @return [PointType]
            attr_reader :point_type
            # @!attribute [r] point
            #   @return [Numeric]
            attr_reader :point
            # @!attribute [r] full_name
            #   @return [String]
            attr_reader :full_name

            # 診療行為コード
            class Code
              include MasterItemCodeInterface

              class << self
                def __name
                  '診療行為'
                end
              end
            end

            # # コード表用番号
            # class CodeHyouYouBangou
            #   def initialize(
            #     code_hyou_you_bangou_alphabet:,
            #     code_hyou_you_bangou_shou:,
            #     code_hyou_you_bangou_kubun_bangou:,
            #     code_hyou_you_bangou_edaban:,
            #     code_hyou_you_bangou_kouban:,
            #     tensuu_hyou_kubun_bangou:
            #   )
            #     @alphabet                 = code_hyou_you_bangou_alphabet
            #     @shou                     = code_hyou_you_bangou_shou
            #     @kubun_bangou             = code_hyou_you_bangou_kubun_bangou
            #     @edaban                   = code_hyou_you_bangou_edaban
            #     @kouban                   = code_hyou_you_bangou_kouban
            #     @tensuu_hyou_kubun_bangou = tensuu_hyou_kubun_bangou
            #   end
            #
            #   # @!attribute [r] alphabet
            #   #   @return [String]
            #   attr_reader :alphabet
            #   # @!attribute [r] shou
            #   #   @return [String]
            #   attr_reader :shou
            #   # @!attribute [r] kubun_bangou
            #   #   @return [String]
            #   attr_reader :kubun_bangou
            #   # @!attribute [r] edaban
            #   #   @return [String]
            #   attr_reader :edaban
            #   # @!attribute [r] kouban
            #   #   @return [String]
            #   attr_reader :kouban
            #   # @!attribute [r] tensuu_hyou_kubun_bangou
            #   #   @return [String]
            #   attr_reader :tensuu_hyou_kubun_bangou
            # end

            # 点数種別
            class PointType
              # @param code [Symbol]
              # @param code [String]
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              # @!attribute [r] code
              #   @return [Symbol]
              attr_reader :code
              # @!attribute [r] name
              #   @return [String]
              attr_reader :name

              @list = {
                '1': new(code: :'1', name: '金額'),
                '3': new(code: :'3', name: '点数(プラス)'),
                '4': new(code: :'4', name: '購入価格(点数)'),
                '5': new(code: :'5', name: '%加算'),
                '6': new(code: :'6', name: '減算'),
                '7': new(code: :'7', name: '減点診療行為'),
                '8': new(code: :'8', name: '点数(マイナス)'),
              }

              class << self
                # @param code [Symbol, Integer, String]
                # @return [self, nil]
                def find_by_code(code)
                  @list[code.to_s.intern]
                end
              end
            end

            # rubocop:disable Metrics/ModuleLength, Layout/SpaceAroundOperators, Layout/ExtraSpacing
            module Columns
              module Columns2022
                C_変更区分                             = 0
                C_マスター種別                         = 1
                C_コード                               = 2
                C_省略名称_漢字有効桁数                = 3
                C_省略名称_漢字名称                    = 4
                C_省略名称_カナ有効桁数                = 5
                C_省略名称_カナ名称                    = 6
                C_データ規格コード                     = 7
                C_データ規格名_漢字有効桁数            = 8
                C_データ規格名_漢字名称                = 9
                C_点数識別                             = 10
                C_新又は現点数                         = 11
                C_入外適用区分                         = 12
                C_後期高齢者区分                       = 13
                C_点数欄集計先識別_入院外              = 14
                C_包括対象検査                         = 15
                C_予備_1                               = 16
                C_DPC適用区分                          = 17
                C_病院・診療所区分                     = 18
                C_画像等手術支援加算                   = 19
                C_医療観察法対象区分                   = 20
                C_看護加算                             = 21
                C_麻酔識別区分                         = 22
                C_予備_2                               = 23
                C_傷病名関連区分                       = 24
                C_予備_3                               = 25
                C_実日数                               = 26
                C_日数・回数                           = 27
                C_医薬品関連区分                       = 28
                C_きざみ値計算識別                     = 29
                C_きざみ値下限値                       = 30
                C_きざみ値上限値                       = 31
                C_きざみ値                             = 32
                C_きざみ点数                           = 33
                C_きざみ値上下限エラー処理             = 34
                C_上限回数                             = 35
                C_上限回数エラー処理                   = 36
                C_注加算コード                         = 37
                C_注加算通番                           = 38
                C_通則年齢                             = 39
                C_下限年齢                             = 40
                C_上限年齢                             = 41
                C_時間加算区分                         = 42
                C_基準適合識別_適合区分                = 43
                C_基準適合識別_対象施設基準            = 44
                C_処置乳幼児加算区分                   = 45
                C_極低出生体重児加算区分               = 46
                C_入院基本料等減算対象識別             = 47
                C_ドナー分集計区分                     = 48
                C_検査等実施判断区分                   = 49
                C_検査等実施判断グループ区分           = 50
                C_逓減対象区分                         = 51
                C_脊髄誘発電位測定加算区分             = 52
                C_頸部郭清術併施加算区分               = 53
                C_自動縫合器使用加算区分               = 54
                C_外来管理加算区分                     = 55
                C_点数識別_旧点数                      = 56
                C_旧点数                               = 57
                C_漢字名称変更区分                     = 58
                C_カナ名称変更区分                     = 59
                C_検体検査コメント                     = 60
                C_通則加算所定点数対象区分             = 61
                C_包括逓減区分                         = 62
                C_超音波内視鏡加算区分                 = 63
                C_予備_4                               = 64
                C_点数欄集計先識別_入院                = 65
                C_自動吻合器使用加算区分               = 66
                C_告示等識別区分_1                     = 67
                C_告示等識別区分_2                     = 68
                C_地域加算                             = 69
                C_病床数区分                           = 70
                C_施設基準コード_1                     = 71
                C_施設基準コード_2                     = 72
                C_施設基準コード_3                     = 73
                C_施設基準コード_4                     = 74
                C_施設基準コード_5                     = 75
                C_施設基準コード_6                     = 76
                C_施設基準コード_7                     = 77
                C_施設基準コード_8                     = 78
                C_施設基準コード_9                     = 79
                C_施設基準コード_10                    = 80
                C_超音波凝固切開装置使用加算区分       = 81
                C_短期滞在手術                         = 82
                C_歯科適用区分                         = 83
                C_コード表用番号_アルファベット部      = 84
                C_告示・通知関連番号__アルファベット部 = 85
                C_変更年月日                           = 86
                C_廃止年月日                           = 87
                C_公表順序番号                         = 88
                C_コード表用番号_章                    = 89
                C_コード表用番号_部                    = 90
                C_コード表用番号_区分番号              = 91
                C_コード表用番号_枝番                  = 92
                C_コード表用番号_項番                  = 93
                C_告示・通知関連番号_章                = 94
                C_告示・通知関連番号_部                = 95
                C_告示・通知関連番号_区分番号          = 96
                C_告示・通知関連番号_枝番              = 97
                C_告示・通知関連番号_項番              = 98
                C_年齢加算_1_下限年齢                  = 99
                C_年齢加算_1_上限年齢                  = 100
                C_年齢加算_1_注加算診療行為コード      = 101
                C_年齢加算_2_下限年齢                  = 102
                C_年齢加算_2_上限年齢                  = 103
                C_年齢加算_2_注加算診療行為コード      = 104
                C_年齢加算_3_下限年齢                  = 105
                C_年齢加算_3_上限年齢                  = 106
                C_年齢加算_3_注加算診療行為コード      = 107
                C_年齢加算_4_下限年齢                  = 108
                C_年齢加算_4_上限年齢                  = 109
                C_年齢加算_4_注加算診療行為コード      = 110
                C_異動関連                             = 111
                C_基本漢字名称                         = 112
                C_副鼻腔手術用内視鏡加算               = 113
                C_副鼻腔手術用骨軟部組織切除機器加算   = 114
                C_長時間麻酔管理加算                   = 115
                C_点数表区分番号                       = 116
                C_モニタリング加算                     = 117
                C_凍結保存同種組織加算                 = 118
                C_悪性腫瘍病理組織標本加算             = 119
                C_創外固定器加算                       = 120
                C_超音波切削機器加算                   = 121
                C_左心耳閉鎖術併施区分                 = 122
                # end more..
              end

              module Columns2020
                C_変更区分                             = 0
                C_マスター種別                         = 1
                C_コード                               = 2
                C_省略名称_漢字有効桁数                = 3
                C_省略名称_漢字名称                    = 4
                C_省略名称_カナ有効桁数                = 5
                C_省略名称_カナ名称                    = 6
                C_データ規格コード                     = 7
                C_データ規格名_漢字有効桁数            = 8
                C_データ規格名_漢字名称                = 9
                C_点数識別                             = 10
                C_新又は現点数                         = 11
                C_入外適用区分                         = 12
                C_後期高齢者区分                       = 13
                C_点数欄集計先識別_入院外              = 14
                C_包括対象検査                         = 15
                C_予備_1                               = 16
                C_DPC適用区分                          = 17
                C_病院・診療所区分                     = 18
                C_画像等手術支援加算                   = 19
                C_医療観察法対象区分                   = 20
                C_看護加算                             = 21
                C_麻酔識別区分                         = 22
                C_予備_2                               = 23
                C_傷病名関連区分                       = 24
                C_予備_3                               = 25
                C_実日数                               = 26
                C_日数・回数                           = 27
                C_医薬品関連区分                       = 28
                C_きざみ値計算識別                     = 29
                C_きざみ値下限値                       = 30
                C_きざみ値上限値                       = 31
                C_きざみ値                             = 32
                C_きざみ点数                           = 33
                C_きざみ値上下限エラー処理             = 34
                C_上限回数                             = 35
                C_上限回数エラー処理                   = 36
                C_注加算コード                         = 37
                C_注加算通番                           = 38
                C_通則年齢                             = 39
                C_下限年齢                             = 40
                C_上限年齢                             = 41
                C_時間加算区分                         = 42
                C_基準適合識別_適合区分                = 43
                C_基準適合識別_対象施設基準            = 44
                C_処置乳幼児加算区分                   = 45
                C_極低出生体重児加算区分               = 46
                C_入院基本料等減算対象識別             = 47
                C_ドナー分集計区分                     = 48
                C_検査等実施判断区分                   = 49
                C_検査等実施判断グループ区分           = 50
                C_逓減対象区分                         = 51
                C_脊髄誘発電位測定加算区分             = 52
                C_頸部郭清術併施加算区分               = 53
                C_自動縫合器使用加算区分               = 54
                C_外来管理加算区分                     = 55
                C_点数識別_旧点数                      = 56
                C_旧点数                               = 57
                C_漢字名称変更区分                     = 58
                C_カナ名称変更区分                     = 59
                C_検体検査コメント                     = 60
                C_通則加算所定点数対象区分             = 61
                C_包括逓減区分                         = 62
                C_超音波内視鏡加算区分                 = 63
                C_予備_4                               = 64
                C_点数欄集計先識別_入院                = 65
                C_自動吻合器使用加算区分               = 66
                C_告示等識別区分_1                     = 67
                C_告示等識別区分_2                     = 68
                C_地域加算                             = 69
                C_病床数区分                           = 70
                C_施設基準コード_1                     = 71
                C_施設基準コード_2                     = 72
                C_施設基準コード_3                     = 73
                C_施設基準コード_4                     = 74
                C_施設基準コード_5                     = 75
                C_施設基準コード_6                     = 76
                C_施設基準コード_7                     = 77
                C_施設基準コード_8                     = 78
                C_施設基準コード_9                     = 79
                C_施設基準コード_10                    = 80
                C_超音波凝固切開装置使用加算区分       = 81
                C_短期滞在手術                         = 82
                C_歯科適用区分                         = 83
                C_コード表用番号_アルファベット部      = 84
                C_告示・通知関連番号__アルファベット部 = 85
                C_変更年月日                           = 86
                C_廃止年月日                           = 87
                C_公表順序番号                         = 88
                C_コード表用番号_章                    = 89
                C_コード表用番号_部                    = 90
                C_コード表用番号_区分番号              = 91
                C_コード表用番号_枝番                  = 92
                C_コード表用番号_項番                  = 93
                C_告示・通知関連番号_章                = 94
                C_告示・通知関連番号_部                = 95
                C_告示・通知関連番号_区分番号          = 96
                C_告示・通知関連番号_枝番              = 97
                C_告示・通知関連番号_項番              = 98
                C_年齢加算_1_下限年齢                  = 99
                C_年齢加算_1_上限年齢                  = 100
                C_年齢加算_1_注加算診療行為コード      = 101
                C_年齢加算_2_下限年齢                  = 102
                C_年齢加算_2_上限年齢                  = 103
                C_年齢加算_2_注加算診療行為コード      = 104
                C_年齢加算_3_下限年齢                  = 105
                C_年齢加算_3_上限年齢                  = 106
                C_年齢加算_3_注加算診療行為コード      = 107
                C_年齢加算_4_下限年齢                  = 108
                C_年齢加算_4_上限年齢                  = 109
                C_年齢加算_4_注加算診療行為コード      = 110
                C_異動関連                             = 111
                C_基本漢字名称                         = 112
                C_副鼻腔手術用内視鏡加算               = 113
                C_副鼻腔手術用骨軟部組織切除機器加算   = 114
                C_長時間麻酔管理加算                   = 115
                C_点数表区分番号                       = 116
                C_モニタリング加算                     = 117
                C_凍結保存同種組織加算                 = 118
                C_悪性腫瘍病理組織標本加算             = 119
                C_創外固定器加算                       = 120
                C_超音波切削機器加算                   = 121
                C_左心耳閉鎖術併施区分                 = 122
              end

              # module Columns2021; end

              # module Columns2018; end

              @versions = {
                # Master::Version::V2018_H30 => Columns2018,
                # Master::Version::V2019_R01 => Columns2019,
                Master::Version::V2020_R02 => Columns2020,
                Master::Version::V2022_R04 => Columns2022,
                Master::Version::V2023_R05 => Columns2022,
              }

              class << self
                # @param version [Master::Version]
                # @return [Module]
                def resolve_columns_by(version)
                  @versions[version]
                end
              end
            end
            # rubocop:enable Metrics/ModuleLength, Layout/SpaceAroundOperators, Layout/ExtraSpacing
          end
        end
      end
    end
  end
end
