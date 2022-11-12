# frozen_string_literal: true

require_relative 'loader/loader_trait'
require_relative 'loader/shinryou_koui_loader'

module Recediff
  module Model
    module ReceiptComputer
      class Master
        class Loader
          IyakuhinCode     = Treatment::Iyakuhin::Code
          TokuteiKizaiCode = Treatment::TokuteiKizai::Code
          CommentCode      = Treatment::Comment::Code
          ShoubyoumeiCode  = Diagnose::Shoubyoumei::Code
          ShuushokugoCode  = Diagnose::Shuushokugo::Code

          # @param resource_resolver [ResourceResolver]
          def initialize(resource_resolver)
            @resource_resolver    = resource_resolver
            @shinryou_koui_loader = ShinryouKouiLoader.new
          end

          # @param version [Version]
          # @return [Master]
          def load(version)
            csv_paths = @resource_resolver.detect_csv_files(version)
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
              shinryou_koui: @shinryou_koui_loader.load(version, shinryou_koui_csv_path),
              iyakuhin:      load_iyakuhin_master(iyakuhin_csv_path),
              tokutei_kizai: load_tokutei_kizai_master(tokutei_kizai_csv_path),
              comment:       load_comment_master(comment_csv_path),
              shoubyoumei:   load_shoubyoumei_master(shoubyoumei_csv_path),
              shuushokugo:   load_shuushokugo_master(shuushokugo_csv_path)
            )
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
                embed_positions = embed_position_columns.each_slice(2).map do | column_start, column_length |
                  start  = values[column_start].to_i
                  length = values[column_length].to_i
                  next if start.zero?

                  Treatment::Comment::EmbedPosition.new(start, length)
                end.compact
                comment = Treatment::Comment.new(
                  code:            CommentCode.of(values[Treatment::Comment::Columns::C_コード]),
                  pattern:         Treatment::Comment::Pattern.find_by_code(
                    values[Treatment::Comment::Columns::C_パターン]
                  ),
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
                  code:      code,
                  name:      values[Diagnose::Shoubyoumei::Columns::C_傷病名_省略名称],
                  full_name: values[Diagnose::Shoubyoumei::Columns::C_傷病名_基本名称],
                  name_kana: convert_katakana(values[Diagnose::Shoubyoumei::Columns::C_傷病名_カナ名称])
                )
              end
            end
          end

          # @param csv_path [String]
          # @return [Hash<Diagnose::Shuushokugo>]
          def load_shuushokugo_master(csv_path)
            kubun2category_code = proc { | value | value[1].intern }

            {}.tap do | hash |
              foreach(csv_path) do | values |
                code             = ShuushokugoCode.of(values[Diagnose::Shuushokugo::Columns::C_コード])
                hash[code.value] = Diagnose::Shuushokugo.new(
                  code:      code,
                  name:      values[Diagnose::Shuushokugo::Columns::C_修飾語名称],
                  name_kana: convert_katakana(values[Diagnose::Shuushokugo::Columns::C_修飾語カナ名称]),
                  category:  Diagnose::Shuushokugo::Category.find_by_code(
                    kubun2category_code.call(values[Diagnose::Shuushokugo::Columns::C_修飾語区分])
                  )
                )
              end
            end
          end
        end
      end
    end
  end
end
