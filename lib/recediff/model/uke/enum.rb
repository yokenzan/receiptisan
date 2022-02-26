# frozen_string_literal: true

module Recediff
  module Model
    module Uke
      module Enum
        C_レコード識別情報 = 0
        # @return [Array<Symbol>]
        def self.records
          constants
        end

        module IR
          RECORD = :IR

          C_レコード識別情報 = 0.freeze
          C_審査支払機関 = 1.freeze
          C_都道府県 = 2.freeze
          C_点数表 = 3.freeze
          C_医療機関コード = 4.freeze
          C_予備_1 = 5.freeze
          C_医療機関名称 = 6.freeze
          C_請求年月 = 7.freeze
          C_マルチボリューム識別情報 = 8.freeze
          C_電話番号 = 9.freeze

          # @return [Array<Symbol>]
          def self.all
            constants
          end
        end

        module RE
          RECORD = :RE

          # レセプト共通レコードを表す識別情報「RE」を記録します。
          C_レコード識別情報 = 0.freeze
          # １レセプトごとに「１」から昇順に連続番号を記録します。
          C_レセプト番号                                     = 1.freeze
          # 当該電子レセプトのレセプト種別コード（別表５）を記録します。
          C_レセプト種別                                     = 2.freeze
          # 当該電子レセプトの診療年月を、「西暦年月6桁」で記録します。
          # 例）令和２年６月診療分の場合・・・・「202006」
          C_診療年月 = 3.freeze
          # ア 全て全角（最大20文字）又は全て半角（最大40文字）で記録します。
          # イ 姓と名の間に、姓名と同じモードのスペースを記録します。
          #   例）姓が「基金（キキン）」、名が「花子（ハナコ）」の場合の記録
          #     全角で記録する場合・・・・「基金 花子」（スペースも全角）
          #     半角で記録する場合・・・・「ｷｷﾝ ﾊﾅｺ」（スペースも半角）
          # ウ 半角で記録された場合であっても、レセプトには全角で表示します。
          #   例）CSVの記録
          #         「ｷｷﾝ ﾊﾅｺ」
          #       レセプトの印字
          #         「キキン ハナコ」
          C_氏名 = 4.freeze
          # 男女区分コード（別表６）を記録します。
          C_男女区分                                         = 5.freeze
          # 年齢に関わらず全ての患者について、「西暦年月日8桁」で記録します。
          # 例）平成5年7月2日生まれの場合・・・・「19930702」
          C_生年月日                                         = 6.freeze
          # 原則的に記録しません。ただし、被爆者健康手帳の交付を受けている場合であって、
          # 国民健康保険の被保険者証の交付を受けていない場合は、「30」を記録します。
          C_給付割合                                         = 7.freeze
          # ア 入院基本料の起算日としての入院年月日を、「西暦年月日8桁」で記録します。
          #   例）令和2年6月12日入院の場合・・・・「20200612」
          # イ その他の場合は、記録を省略します。
          C_入院年月日 = 8.freeze
          # ア 患者が入院している病院又は病棟に応じ、病棟区分コード（別表７）を記録します。
          #   月の途中において病棟を移った場合は、そのすべてを記録します。（最大4区分の記録が可能）
          #   例１）精神病棟に入院している場合・・・・「01」
          #   例２）月途中で結核病棟から療養病棟へ病棟を移動した場合・・・・「0207」
          # イ その他の場合は、記録を省略します。
          C_病棟区分 = 9.freeze
          # ア 入院時負担金額又は外来時一部負担金額並びに食事療養費又は生活療養費に
          #   係る標準負担額について、限度額適用・標準負担額減額認定証等の提示を受けた場合、
          #   一部負担金・食事療養費・生活療養費標準負担額区分コード（別表８）を記録します。
          # イ その他の場合は、記録を省略します。
          C_一部負担金・食事療養費・生活療養費標準負担額区分 = 10.freeze
          # ア 患者が特記事項に該当する場合、レセプト特記事項コード（別表９）を記録します。
          #   （最大５つまで記録可能）
          # イ その他の場合は、記録を省略します。
          C_レセプト特記事項 = 11.freeze
          C_病床数 = 12.freeze
          C_カルテ番号等                                     = 13.freeze
          C_割引点数単価                                     = 14.freeze
          C_予備_1                                           = 15.freeze
          C_予備_2                                           = 16.freeze
          C_予備_3                                           = 17.freeze
          C_検索番号 = 18.freeze
          C_予備_4_記録条件仕様年月情報 = 19.freeze
          C_請求情報 = 20.freeze
          C_診療科_1_診療科名 = 21.freeze
          C_診療科_1_人体の部位等 = 22.freeze
          C_診療科_1_性別等 = 23.freeze
          C_診療科_1_医学的処置 = 24.freeze
          C_診療科_1_特定疾病                                = 25.freeze
          C_診療科_2_診療科名                                = 26.freeze
          C_診療科_2_人体の部位等 = 27.freeze
          C_診療科_2_性別等 = 28.freeze
          C_診療科_2_医学的処置 = 29.freeze
          C_診療科_2_特定疾病                                = 30.freeze
          C_診療科_3_診療科名                                = 31.freeze
          C_診療科_3_人体の部位等 = 32.freeze
          C_診療科_3_性別等 = 33.freeze
          C_診療科_3_医学的処置 = 34.freeze
          C_診療科_3_特定疾病 = 35.freeze
          C_カタカナ氏名 = 36.freeze
          C_患者の状態 = 37.freeze

          # @return [Array<Symbol>]
          def self.all
            constants
          end
        end

        module SI
          RECORD = :SI

          # 診療行為レコードを表す識別情報「SI」を記録します。
          C_レコード識別情報 = 0.freeze
          # ア 当該診療行為が属する診療識別コード（別表２０）を記録する場合は、
          #   診療識別ごとの先頭レコードに記録します。
          #   詳細については、「第14章 摘要情報共通の記録方法」を参照ください。
          # イ 診療識別の記録ごとに、自動的に昇順の診療識別内一連番号を付与します。
          #   （レコード項目のCSV翻訳情報は全て「01」からの昇順で説明しています。）
          C_診療識別                  = 1.freeze
          # 各々の診療行為をどの保険が負担するのかを識別するための負担区分コード（別表２１）
          # を記録します。詳細については、「第14章 摘要情報共通の記録方法」を参照ください。
          C_負担区分                  = 2.freeze
          # ９桁の診療行為コードを記録します。点数及び回数に関連した事項については、（6）及び（7）を参照ください。
          C_レセ電コード = 3.freeze
          # ア きざみ値計算識別が「1」の診療行為コードについては、そのデータ規格名の単位に従い、
          #   「0」より大きい整数値を必ず記録します。
          # イ きざみ値計算識別が「0」の診療行為コードについては、数量データを記録しません。
          C_数量データ = 4.freeze
          C_点数                      = 5.freeze
          # 9桁の診療行為コード、診療行為の点数を記録します。
          C_回数                      = 6.freeze
          C_コメント_1_コメントコード = 7.freeze
          C_コメント_1_文字データ = 8.freeze
          C_コメント_2_コメントコード = 9.freeze
          C_コメント_2_文字データ = 10.freeze
          C_コメント_3_コメントコード = 11.freeze
          C_コメント_3_文字データ = 12.freeze
          C_算定日_1日                = 13.freeze
          C_算定日_2日                = 14.freeze
          C_算定日_3日                = 15.freeze
          C_算定日_4日                = 16.freeze
          C_算定日_5日                = 17.freeze
          C_算定日_6日                = 18.freeze
          C_算定日_7日                = 19.freeze
          C_算定日_8日                = 20.freeze
          C_算定日_9日                = 21.freeze
          C_算定日_10日               = 22.freeze
          C_算定日_11日               = 23.freeze
          C_算定日_12日               = 24.freeze
          C_算定日_13日               = 25.freeze
          C_算定日_14日               = 26.freeze
          C_算定日_15日               = 27.freeze
          C_算定日_16日               = 28.freeze
          C_算定日_17日               = 29.freeze
          C_算定日_18日               = 30.freeze
          C_算定日_19日               = 31.freeze
          C_算定日_20日               = 32.freeze
          C_算定日_21日               = 33.freeze
          C_算定日_22日               = 34.freeze
          C_算定日_23日               = 35.freeze
          C_算定日_24日               = 36.freeze
          C_算定日_25日               = 37.freeze
          C_算定日_26日               = 38.freeze
          C_算定日_27日               = 39.freeze
          C_算定日_28日               = 40.freeze
          C_算定日_29日               = 41.freeze
          C_算定日_30日               = 42.freeze
          C_算定日_31日               = 43.freeze

          # @return [Array<Symbol>]
          def self.all
            constants
          end
        end

        module IY
          RECORD = :IY

          C_レコード識別情報 = 0.freeze
          C_診療識別                  = 1.freeze
          C_負担区分                  = 2.freeze
          C_レセ電コード = 3.freeze
          C_使用量 = 4.freeze
          C_点数                      = 5.freeze
          C_回数                      = 6.freeze
          C_コメント_1_コメントコード = 7.freeze
          C_コメント_1_文字データ = 8.freeze
          C_コメント_2_コメントコード = 9.freeze
          C_コメント_2_文字データ = 10.freeze
          C_コメント_3_コメントコード = 11.freeze
          C_コメント_3_文字データ = 12.freeze
          C_算定日_1日                = 13.freeze
          C_算定日_2日                = 14.freeze
          C_算定日_3日                = 15.freeze
          C_算定日_4日                = 16.freeze
          C_算定日_5日                = 17.freeze
          C_算定日_6日                = 18.freeze
          C_算定日_7日                = 19.freeze
          C_算定日_8日                = 20.freeze
          C_算定日_9日                = 21.freeze
          C_算定日_10日               = 22.freeze
          C_算定日_11日               = 23.freeze
          C_算定日_12日               = 24.freeze
          C_算定日_13日               = 25.freeze
          C_算定日_14日               = 26.freeze
          C_算定日_15日               = 27.freeze
          C_算定日_16日               = 28.freeze
          C_算定日_17日               = 29.freeze
          C_算定日_18日               = 30.freeze
          C_算定日_19日               = 31.freeze
          C_算定日_20日               = 32.freeze
          C_算定日_21日               = 33.freeze
          C_算定日_22日               = 34.freeze
          C_算定日_23日               = 35.freeze
          C_算定日_24日               = 36.freeze
          C_算定日_25日               = 37.freeze
          C_算定日_26日               = 38.freeze
          C_算定日_27日               = 39.freeze
          C_算定日_28日               = 40.freeze
          C_算定日_29日               = 41.freeze
          C_算定日_30日               = 42.freeze
          C_算定日_31日               = 43.freeze

          # @return [Array<Symbol>]
          def self.all
            constants
          end
        end

        module TO
          RECORD = :TO

          C_レコード識別情報 = 0.freeze
          C_診療識別                  = 1.freeze
          C_負担区分                  = 2.freeze
          C_レセ電コード = 3.freeze
          C_使用量 = 4.freeze
          C_点数                      = 5.freeze
          C_回数                      = 6.freeze
          C_単位コード = 7.freeze
          C_単価                      = 8.freeze
          C_予備_1                    = 9.freeze
          C_商品名及び規格又はサイズ = 10.freeze
          C_コメント_1_コメントコード = 11.freeze
          C_コメント_1_文字データ = 12.freeze
          C_コメント_2_コメントコード = 13.freeze
          C_コメント_2_文字データ = 14.freeze
          C_コメント_3_コメントコード = 15.freeze
          C_コメント_3_文字データ = 16.freeze
          C_算定日_1日                = 17.freeze
          C_算定日_2日                = 18.freeze
          C_算定日_3日                = 19.freeze
          C_算定日_4日                = 20.freeze
          C_算定日_5日                = 21.freeze
          C_算定日_6日                = 22.freeze
          C_算定日_7日                = 23.freeze
          C_算定日_8日                = 24.freeze
          C_算定日_9日                = 25.freeze
          C_算定日_10日               = 26.freeze
          C_算定日_11日               = 27.freeze
          C_算定日_12日               = 28.freeze
          C_算定日_13日               = 29.freeze
          C_算定日_14日               = 30.freeze
          C_算定日_15日               = 31.freeze
          C_算定日_16日               = 32.freeze
          C_算定日_17日               = 33.freeze
          C_算定日_18日               = 34.freeze
          C_算定日_19日               = 35.freeze
          C_算定日_20日               = 36.freeze
          C_算定日_21日               = 37.freeze
          C_算定日_22日               = 38.freeze
          C_算定日_23日               = 39.freeze
          C_算定日_24日               = 40.freeze
          C_算定日_25日               = 41.freeze
          C_算定日_26日               = 42.freeze
          C_算定日_27日               = 43.freeze
          C_算定日_28日               = 44.freeze
          C_算定日_29日               = 45.freeze
          C_算定日_30日               = 46.freeze
          C_算定日_31日               = 47.freeze

          # @return [Array<Symbol>]
          def self.all
            constants
          end
        end

        module CO
          RECORD = :CO

          C_レコード識別情報 = 0.freeze
          C_診療識別         = 1.freeze
          C_負担区分         = 2.freeze
          C_コメントコード = 3.freeze
          C_文字データ = 4.freeze

          # @return [Array<Symbol>]
          def self.all
            constants
          end
        end
      end
    end
  end
end
