# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class Master
        class Loader
          class ShuushokugoLoader
            include LoaderTrait

            # @param csv_path [String]
            # @return [Hash<Symbol, Diagnose::Shuushokugo>]
            def load(csv_path)
              {}.tap do | hash |
                foreach(csv_path) do | values |
                  code             = Diagnose::Shuushokugo::Code.of(values[Diagnose::Shuushokugo::Columns::C_コード])
                  hash[code.value] = Diagnose::Shuushokugo.new(
                    code:      code,
                    name:      values[Diagnose::Shuushokugo::Columns::C_修飾語名称],
                    name_kana: convert_katakana(values[Diagnose::Shuushokugo::Columns::C_修飾語カナ名称]),
                    category:  Diagnose::Shuushokugo::Category.find_by_code(
                      kubun2category_code(values[Diagnose::Shuushokugo::Columns::C_修飾語区分])
                    )
                  )
                end
              end
            end

            private

            # @return [Symbol]
            def kubun2category_code(kubun)
              kubun[1].intern
            end
          end
        end
      end
    end
  end
end
