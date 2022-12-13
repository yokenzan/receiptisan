# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class Loader
          class ShoubyoumeiLoader
            include LoaderTrait

            # @param csv_paths [Array<String>]
            # @return [Hash<Symbol, Diagnosis::Shoubyoumei>]
            def load(csv_paths)
              {}.tap do | hash |
                foreach(csv_paths) do | values |
                  code             = Diagnosis::Shoubyoumei::Code.of(values[Diagnosis::Shoubyoumei::Columns::C_コード])
                  hash[code.value] = Diagnosis::Shoubyoumei.new(
                    code:      code,
                    name:      values[Diagnosis::Shoubyoumei::Columns::C_傷病名_省略名称],
                    full_name: values[Diagnosis::Shoubyoumei::Columns::C_傷病名_基本名称],
                    name_kana: convert_katakana(values[Diagnosis::Shoubyoumei::Columns::C_傷病名_カナ名称])
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end
