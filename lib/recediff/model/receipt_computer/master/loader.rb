# frozen_string_literal: true

require 'nkf'
require 'pathname'

module Recediff
  module Model
    module ReceiptComputer
      class Master
        class Loader # rubocop:disable Metrics/ClassLength
          # レセプト電算処理システム基本マスターファイルのディレクトリへの相対パス
          MASTER_CSV_DIR      = '../../../../../csv/master'
          # マスターファイルの文字コード
          MASTER_CSV_ENCODING = 'Shift_JIS'

          # @param version [Version]
          # @return [Master]
          def load(version)
            pathname     = resolve_csv_dir_of(version)
            csv_files    = pathname.children
            csv_paths    = {}
            csv_prefixes = {
              shinryou_koui: 's',
              iyakuhin:      'y',
              tokutei_kizai: 't',
              comment:       'c',
              shoubyoumei:   'b',
              shuushokugo:   'z',
            }
            csv_prefixes.each do | key, value |
              csv_paths["#{key}_csv_path".intern] = csv_files.delete_at(
                # @param csv [Pathname]
                csv_files.find_index { | csv | csv.basename.to_path.start_with?(value) }
              )
            end

            load_from_version_and_csv(version, **csv_paths)
          end

          # @param version [Version]
          # @param shinryou_koui_csv_path [String]
          # @param iyakuhin_csv_path [String]
          # @param tokutei_kizai_csv_path [String]
          # @param comment_csv_path [String]
          # @param shoubyoumei_csv_path [String]
          # @param shuushokugo_csv_path [String]
          # @return [Master]
          def load_from_version_and_csv(
            version,
            shinryou_koui_csv_path:,
            iyakuhin_csv_path:,
            tokutei_kizai_csv_path:,
            comment_csv_path:,
            shoubyoumei_csv_path:,
            shuushokugo_csv_path:
          )
            Master.new(
              shinryou_koui: load_shinryou_koui_master(version, shinryou_koui_csv_path),
              iyakuhin:      load_iyakuhin_master(iyakuhin_csv_path),
              tokutei_kizai: load_tokutei_kizai_master(tokutei_kizai_csv_path),
              comment:       load_comment_master(comment_csv_path),
              shoubyoumei:   load_shoubyoumei_master(shoubyoumei_csv_path),
              shuushokugo:   load_shuushokugo_master(shuushokugo_csv_path)
            )
          end

          private

          # @param version [Version]
          # @return [Pathname]
          def resolve_csv_dir_of(version)
            pathname  = Pathname.new(MASTER_CSV_DIR)
            pathname += version.year.to_s
            pathname.expand_path(__dir__)
          end

          # @param version [Version]
          # @param csv_path [String]
          # @return [Hash<Treatment::ShinryouKoui>]
          def load_shinryou_koui_master(version, csv_path)
            {}.tap do | hash |
              columns = Treatment::ShinryouKoui::Columns.resolve_columns_by(version)
              foreach(csv_path) do | values |
                code             = ShinryouKouiCode.of(values[columns::C_コード])
                hash[code.value] = Treatment::ShinryouKoui.new(
                  code:                              code,
                  short_name:                        values[columns::C_省略名称_漢字名称],
                  short_name_kana:                   convert_katakana(values[columns::C_省略名称_カナ名称]),
                  unit:                              Unit.find_by_code(values[columns::C_データ規格コード]),
                  price_type:                        Treatment::PriceType.new(values[columns::C_点数識別]),
                  point:                             values[columns::C_新又は現点数],
                  shuukeisaki_shikibetu_gairai:      values[columns::C_点数欄集計先識別_入院外],
                  shuukeisaki_shikibetu_nyuuin:      values[columns::C_点数欄集計先識別_入院],
                  code_hyou_you_bangou_alphabet:     values[columns::C_コード表用番号_アルファベット部],
                  code_hyou_you_bangou_shou:         values[columns::C_コード表用番号_章],
                  code_hyou_you_bangou_kubun_bangou: values[columns::C_コード表用番号_区分番号],
                  code_hyou_you_bangou_edaban:       values[columns::C_コード表用番号_枝番],
                  code_hyou_you_bangou_kouban:       values[columns::C_コード表用番号_項番],
                  tensuu_hyou_kubun_bangou:          values[columns::C_点数表区分番号],
                  full_name:                         values[columns::C_基本漢字名称]
                )
              end
            end
          end

          # @param csv_path [String]
          # @return [Hash<Treatment::Iyakuhin>]
          def load_iyakuhin_master(csv_path)
            {}.tap do | hash |
              foreach(csv_path) do | values |
                code             = IyakuhinCode.of(values[Treatment::Iyakuhin::Columns::C_コード])
                hash[code.value] = Treatment::Iyakuhin.new(
                  code:            code,
                  name:            values[Treatment::Iyakuhin::Columns::C_医薬品名・規格名_漢字名称],
                  name_kana:       convert_katakana(values[Treatment::Iyakuhin::Columns::C_医薬品名・規格名_カナ名称]),
                  unit:            Unit.find_by_code(values[Treatment::Iyakuhin::Columns::C_単位_コード]),
                  price_type:      Treatment::PriceType.new(values[Treatment::Iyakuhin::Columns::C_金額種別]),
                  price:           values[Treatment::Iyakuhin::Columns::C_新又は現金額],
                  chuusha_youryou: values[Treatment::Iyakuhin::Columns::C_注射容量],
                  dosage_form:     values[Treatment::Iyakuhin::Columns::C_剤形],
                  full_name:       values[Treatment::Iyakuhin::Columns::C_基本漢字名称]
                )
              end
            end
          end

          # @param csv_path [String]
          # @return [Hash<Treatment::TokuteiKizai>]
          def load_tokutei_kizai_master(csv_path)
            {}.tap do | hash |
              foreach(csv_path) do | values |
                code             = TokuteiKizaiCode.of(values[Treatment::TokuteiKizai::Columns::C_コード])
                hash[code.value] = Treatment::TokuteiKizai.new(
                  code:       code,
                  name:       values[Treatment::TokuteiKizai::Columns::C_特定器材名・規格名_漢字名称],
                  name_kana:  convert_katakana(values[Treatment::TokuteiKizai::Columns::C_特定器材名・規格名_カナ名称]),
                  unit:       Unit.find_by_code(values[Treatment::TokuteiKizai::Columns::C_単位_コード]),
                  price_type: Treatment::PriceType.new(values[Treatment::TokuteiKizai::Columns::C_金額種別]),
                  price:      values[Treatment::TokuteiKizai::Columns::C_新又は現金額],
                  full_name:  values[Treatment::TokuteiKizai::Columns::C_基本漢字名称]
                )
              end
            end
          end

          # @param csv_path [String]
          # @return [Hash<Treatment::Comment>]
          def load_comment_master(csv_path)
            embed_position_columns = [
              Treatment::Comment::Columns::C_レセプト編集情報_1_カラム位置,
              Treatment::Comment::Columns::C_レセプト編集情報_1_桁数,
              Treatment::Comment::Columns::C_レセプト編集情報_2_カラム位置,
              Treatment::Comment::Columns::C_レセプト編集情報_2_桁数,
              Treatment::Comment::Columns::C_レセプト編集情報_3_カラム位置,
              Treatment::Comment::Columns::C_レセプト編集情報_3_桁数,
              Treatment::Comment::Columns::C_レセプト編集情報_4_カラム位置,
              Treatment::Comment::Columns::C_レセプト編集情報_4_桁数,
            ]
            {}.tap do | hash |
              foreach(csv_path) do | values |
                embed_positions = embed_position_columns.each_slice(2).map do | position, length |
                  Treatment::Comment::EmbedPosition.new(position, length)
                end
                comment = Treatment::Comment.new(
                  code:            CommentCode.of(values[Treatment::Comment::Columns::C_コード]),
                  pattern:         values[Treatment::Comment::Columns::C_パターン],
                  name:            values[Treatment::Comment::Columns::C_コメント文_漢字名称],
                  name_kana:       convert_katakana(values[Treatment::Comment::Columns::C_コメント文_カナ名称]),
                  embed_positions: embed_positions
                )
                hash[comment.code.value] = comment
              end
            end
          end

          # @param csv_path [String]
          # @return [Hash<Diagnose::Shoubyoumei>]
          def load_shoubyoumei_master(csv_path)
            {}.tap do | hash |
              foreach(csv_path) do | values |
                code             = ShoubyoumeiCode.of(values[Diagnose::Shoubyoumei::Columns::C_コード])
                hash[code.value] = Diagnose::Shoubyoumei.new(
                  code:       code,
                  full_name:  values[Diagnose::Shoubyoumei::Columns::C_傷病名_基本名称],
                  short_name: values[Diagnose::Shoubyoumei::Columns::C_傷病名_省略名称],
                  name_kana:  convert_katakana(values[Diagnose::Shoubyoumei::Columns::C_傷病名_カナ名称])
                )
              end
            end
          end

          # @param csv_path [String]
          # @return [Hash<Diagnose::Shuushokugo>]
          def load_shuushokugo_master(csv_path)
            {}.tap do | hash |
              foreach(csv_path) do | values |
                code             = ShuushokugoCode.of(values[Diagnose::Shuushokugo::Columns::C_コード])
                hash[code.value] = Diagnose::Shuushokugo.new(
                  code:      code,
                  name:      values[Diagnose::Shuushokugo::Columns::C_修飾語名称],
                  name_kana: convert_katakana(values[Diagnose::Shuushokugo::Columns::C_修飾語カナ名称]),
                  category:  values[Diagnose::Shuushokugo::Columns::C_修飾語区分]
                )
              end
            end
          end

          # simple copy of `CSV.foreach()`
          #
          # @param csv_path [String]
          # @return [void]
          # @yieldparam values [Array<String, nil>]
          # @yieldreturn [void]
          def foreach(csv_path)
            File.open(csv_path, "r:#{MASTER_CSV_ENCODING}:UTF-8") do | f |
              f.each_line(chomp: true) { | line | yield line.tr('"', '').split(',') }
            end
          end

          # 半角カナ→全角カナに変換する
          #
          # @param hankaku [String]
          # @return [String]
          def convert_katakana(hankaku)
            NKF.nkf('-wWX', hankaku)
          end
        end
      end
    end
  end
end
