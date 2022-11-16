# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class Master
        class Loader
          class ShinryouKouiLoader
            include LoaderTrait

            # @param version [Version]
            # @param csv_path [String]
            # @return [Hash<Symbol, Treatment::ShinryouKoui>]
            def load(version, csv_path)
              {}.tap do | hash |
                unless (columns = Treatment::ShinryouKoui::Columns.resolve_columns_by(version))
                  raise ShinryouKouiSchemaNotFoundError, "#{version} ShinryouKoui Master schema not found"
                end

                foreach(csv_path) do | values |
                  code             = Treatment::ShinryouKoui::Code.of(values[columns::C_コード])
                  hash[code.value] = Treatment::ShinryouKoui.new(
                    code:                         code,
                    name:                         values[columns::C_省略名称_漢字名称],
                    name_kana:                    convert_katakana(values[columns::C_省略名称_カナ名称]),
                    unit:                         Unit.find_by_code(values[columns::C_データ規格コード]),
                    point_type:                   Treatment::ShinryouKoui::PointType.find_by_code(
                      values[columns::C_点数識別].intern
                    ),
                    point:                        values[columns::C_新又は現点数].to_i,
                    shuukeisaki_shikibetu_gairai: values[columns::C_点数欄集計先識別_入院外],
                    shuukeisaki_shikibetu_nyuuin: values[columns::C_点数欄集計先識別_入院],
                    # code_hyou_you_bangou_alphabet:     values[columns::C_コード表用番号_アルファベット部],
                    # code_hyou_you_bangou_shou:         values[columns::C_コード表用番号_章],
                    # code_hyou_you_bangou_kubun_bangou: values[columns::C_コード表用番号_区分番号],
                    # code_hyou_you_bangou_edaban:       values[columns::C_コード表用番号_枝番],
                    # code_hyou_you_bangou_kouban:       values[columns::C_コード表用番号_項番],
                    # tensuu_hyou_kubun_bangou:          values[columns::C_点数表区分番号],
                    full_name:                    values[columns::C_基本漢字名称]
                  )
                end
              end
            end
          end

          class ShinryouKouiSchemaNotFoundError < StandardError; end
        end
      end
    end
  end
end
