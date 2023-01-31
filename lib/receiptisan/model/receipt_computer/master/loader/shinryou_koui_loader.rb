# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class Loader
          class ShinryouKouiLoader
            include LoaderTrait

            # @param version [Version]
            # @param csv_paths [Array<String>]
            # @return [Hash<Symbol, Treatment::ShinryouKoui>]
            def load(version, csv_paths)
              {}.tap do | hash |
                unless (columns = Treatment::ShinryouKoui::Columns.resolve_columns_by(version))
                  raise ShinryouKouiSchemaNotFoundError, "#{version} ShinryouKoui Master schema not found"
                end

                foreach(csv_paths) do | values |
                  code             = Treatment::ShinryouKoui::Code.of(values[columns::C_コード])
                  hash[code.value] = Treatment::ShinryouKoui.new(
                    code:       code,
                    name:       replace_kakkotsuki_mark(
                      convert_unit(values[columns::C_省略名称_漢字名称])
                    ),
                    name_kana:  convert_katakana(values[columns::C_省略名称_カナ名称]),
                    unit:       Unit.find_by_code(values[columns::C_データ規格コード]),
                    point_type: Treatment::ShinryouKoui::PointType.find_by_code(
                      values[columns::C_点数識別].intern
                    ),
                    point:      values[columns::C_新又は現点数].to_i,
                    full_name:  values[columns::C_基本漢字名称]
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
