# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class Loader
          class TokuteiKizaiLoader
            include LoaderTrait

            def initialize(logger)
              @logger = logger
            end

            # @param csv_paths [Array<String>]
            # @return [Hash<Symbol, Treatment::TokuteiKizai>]
            def load(csv_paths)
              {}.tap do | hash |
                foreach(csv_paths) do | values |
                  code             = Treatment::TokuteiKizai::Code.of(values[Treatment::TokuteiKizai::Columns::C_コード])
                  hash[code.value] = Treatment::TokuteiKizai.new(
                    code:       code,
                    name:       replace_kakkotsuki_mark(
                      convert_unit(values[Treatment::TokuteiKizai::Columns::C_特定器材名・規格名_漢字名称])
                    ),
                    name_kana:  convert_katakana(values[Treatment::TokuteiKizai::Columns::C_特定器材名・規格名_カナ名称]),
                    unit:       Unit.find_by_code(values[Treatment::TokuteiKizai::Columns::C_単位_コード]),
                    price_type: Treatment::TokuteiKizai::PriceType.find_by_code(
                      values[Treatment::TokuteiKizai::Columns::C_金額種別].intern
                    ),
                    price:      values[Treatment::TokuteiKizai::Columns::C_新又は現金額]&.to_f,
                    full_name:  values[Treatment::TokuteiKizai::Columns::C_基本漢字名称]
                  )
                end
              end
            end

            private

            attr_reader :logger
          end
        end
      end
    end
  end
end
