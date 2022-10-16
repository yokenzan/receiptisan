# frozen_string_literal: true

require 'nkf'
require 'pathname'
require_relative 'master/version'
require_relative 'master/treatment'
require_relative 'master/diagnose'

module Recediff
  module Model
    module ReceiptComputer
      class Master # rubocop:disable Metrics/ClassLength
        class << self
          MASTER_CSV_DIR = '../../../../csv/master'

          # @param version [Version]
          # @return [self]
          def load(version)
            pathname     = resolve_csv_dir_of(version)
            # @type [Array<String>]
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
                csv_files.find_index { | c | c.basename.to_path.start_with?(value) }
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
          # @return [self]
          def load_from_version_and_csv(
            version,
            shinryou_koui_csv_path:,
            iyakuhin_csv_path:,
            tokutei_kizai_csv_path:,
            comment_csv_path:,
            shoubyoumei_csv_path:,
            shuushokugo_csv_path:
          )
            new(
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
              columns = Treatment::ShinryouKoui::Columns.resolve_columns_by_master_version(version)

              File.open(csv_path, 'r:Windows-31J:UTF-8') do | f |
                f.each_line(chomp: true) do | row |
                  row        = row.tr('"', '').split(',')
                  code       = row[columns::C_コード]
                  hash[code] = Treatment::ShinryouKoui.new(
                    code:                              code,
                    short_name:                        row[columns::C_省略名称_漢字名称],
                    short_name_kana:                   convert_katakana(row[columns::C_省略名称_カナ名称]),
                    unit:                              Unit.new(
                      code: row[columns::C_データ規格コード],
                      name: row[columns::C_データ規格名_漢字名称]
                    ),
                    price_type:                        Treatment::PriceType.new(row[columns::C_点数識別]),
                    point:                             row[columns::C_新又は現点数],
                    shuukeisaki_shikibetu_gairai:      row[columns::C_点数欄集計先識別_入院外],
                    shuukeisaki_shikibetu_nyuuin:      row[columns::C_点数欄集計先識別_入院],
                    code_hyou_you_bangou_alphabet:     row[columns::C_コード表用番号_章],
                    code_hyou_you_bangou_shou:         row[columns::C_コード表用番号_部],
                    code_hyou_you_bangou_kubun_bangou: row[columns::C_コード表用番号_区分番号],
                    code_hyou_you_bangou_kubun_edaban: row[columns::C_コード表用番号_枝番],
                    code_hyou_you_bangou_kubun_kouban: row[columns::C_コード表用番号_項番],
                    tensuu_hyou_kubun_bangou:          row[columns::C_点数表区分番号],
                    full_name:                         row[columns::C_基本漢字名称]
                  )
                end
              end
            end
          end

          # @param csv_path [String]
          # @return [Hash<Treatment::Iyakuhin>]
          def load_iyakuhin_master(csv_path)
            {}.tap do | hash |
              File.open(csv_path, 'r:Windows-31J:UTF-8') do | f |
                f.each_line(chomp: true) do | row |
                  row        = row.tr('"', '').split(',')
                  code       = row[Treatment::Iyakuhin::Columns::C_コード]
                  hash[code] = Treatment::Iyakuhin.new(
                    code:            code,
                    name:            row[Treatment::Iyakuhin::Columns::C_医薬品名・規格名_漢字名称],
                    name_kana:       convert_katakana(row[Treatment::Iyakuhin::Columns::C_医薬品名・規格名_カナ名称]),
                    unit:            Unit.new(
                      code: row[Treatment::Iyakuhin::Columns::C_単位_コード],
                      name: row[Treatment::Iyakuhin::Columns::C_単位_漢字名称]
                    ),
                    price_type:      Treatment::PriceType.new(row[Treatment::Iyakuhin::Columns::C_金額種別]),
                    price:           row[Treatment::Iyakuhin::Columns::C_新又は現金額],
                    chuusha_youryou: row[Treatment::Iyakuhin::Columns::C_新又は現金額],
                    dosage_form:     row[Treatment::Iyakuhin::Columns::C_剤形],
                    full_name:       row[Treatment::Iyakuhin::Columns::C_基本漢字名称]
                  )
                end
              end
            end
          end

          # @param csv_path [String]
          # @return [Hash<Treatment::TokuteiKizai>]
          def load_tokutei_kizai_master(csv_path)
            {}.tap do | hash |
              File.open(csv_path, 'r:Windows-31J:UTF-8') do | f |
                f.each_line(chomp: true) do | row |
                  row        = row.tr('"', '').split(',')
                  code       = row[Treatment::TokuteiKizai::Columns::C_コード]
                  hash[code] = Treatment::TokuteiKizai.new(
                    code:       code,
                    name:       row[Treatment::TokuteiKizai::Columns::C_特定器材名・規格名_漢字名称],
                    name_kana:  convert_katakana(row[Treatment::TokuteiKizai::Columns::C_特定器材名・規格名_カナ名称]),
                    unit:       Unit.new(
                      code: row[Treatment::TokuteiKizai::Columns::C_単位_コード],
                      name: row[Treatment::TokuteiKizai::Columns::C_単位_漢字名称]
                    ),
                    price_type: Treatment::PriceType.new(row[Treatment::TokuteiKizai::Columns::C_金額種別]),
                    price:      row[Treatment::TokuteiKizai::Columns::C_新又は現金額],
                    full_name:  row[Treatment::TokuteiKizai::Columns::C_基本漢字名称]
                  )
                end
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
              File.open(csv_path, 'r:Windows-31J:UTF-8') do | f |
                f.each_line(chomp: true) do | row |
                  comment = Treatment::Comment.new(
                    code:      row[Treatment::Comment::Columns::C_コード],
                    pattern:   row[Treatment::Comment::Columns::C_パターン],
                    name:      row[Treatment::Comment::Columns::C_コメント文_漢字名称],
                    name_kana: convert_katakana(row[Treatment::Comment::Columns::C_コメント文_カナ名称])
                  )
                  embed_position_columns.each_slice(2) do | position, length |
                    comment.embed_positions << Treatment::Comment::EmbedPosition.new(position, length)
                  end
                  hash[comment.code] = comment
                end
              end
            end
          end

          # @param csv_path [String]
          # @return [Hash<Diagnose::Shoubyoumei>]
          def load_shoubyoumei_master(csv_path)
            {}.tap do | hash |
              File.open(csv_path, 'r:Windows-31J:UTF-8') do | f |
                f.each_line(chomp: true) do | row |
                  code       = row[Diagnose::Shoubyoumei::Columns::C_コード]
                  hash[code] = Diagnose::Shoubyoumei.new(
                    code:       code,
                    full_name:  row[Diagnose::Shoubyoumei::Columns::C_傷病名_基本名称],
                    short_name: row[Diagnose::Shoubyoumei::Columns::C_傷病名_省略名称],
                    name_kana:  convert_katakana(row[Diagnose::Shoubyoumei::Columns::C_傷病名_カナ名称])
                  )
                end
              end
            end
          end

          # @param csv_path [String]
          # @return [Hash<Diagnose::Shuushokugo>]
          def load_shuushokugo_master(csv_path)
            {}.tap do | hash |
              File.open(csv_path, 'r:Windows-31J:UTF-8') do | f |
                f.each_line(chomp: true) do | row |
                  code       = row[Diagnose::Shuushokugo::Columns::C_コード]
                  hash[code] = Diagnose::Shuushokugo.new(
                    code:      code,
                    name:      row[Diagnose::Shuushokugo::Columns::C_修飾語名称],
                    name_kana: convert_katakana(row[Diagnose::Shuushokugo::Columns::C_修飾語カナ名称])
                  )
                end
              end
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
        end
      end
    end
  end
end

Recediff::Model::ReceiptComputer::Master.load(
  Recediff::Model::ReceiptComputer::Master::Version::V2022_R04
)
