# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class Loader
          class IyakuhinLoader
            include LoaderTrait

            def initialize(logger)
              @logger = logger
            end

            # @param csv_paths [Array<String>]
            # @return [Hash<Symbol, Treatment::Iyakuhin>]
            def load(csv_paths)
              {}.tap do | hash |
                foreach(csv_paths) do | values |
                  code             = Treatment::Iyakuhin::Code.of(values[Treatment::Iyakuhin::Columns::C_コード])
                  hash[code.value] = Treatment::Iyakuhin.new(
                    code:            code,
                    name:            replace_kakkotsuki_mark(
                      convert_unit(values[Treatment::Iyakuhin::Columns::C_医薬品名・規格名_漢字名称])
                    ),
                    name_kana:       convert_katakana(values[Treatment::Iyakuhin::Columns::C_医薬品名・規格名_カナ名称]),
                    unit:            Unit.find_by_code(values[Treatment::Iyakuhin::Columns::C_単位_コード]),
                    price_type:      Treatment::Iyakuhin::PriceType.find_by_code(
                      values[Treatment::Iyakuhin::Columns::C_金額種別].intern
                    ),
                    price:           values[Treatment::Iyakuhin::Columns::C_新又は現金額]&.to_f,
                    chuusha_youryou: values[Treatment::Iyakuhin::Columns::C_注射容量].to_i.zero? ?
                      nil :
                      values[Treatment::Iyakuhin::Columns::C_注射容量].to_i,
                    dosage_form:     values[Treatment::Iyakuhin::Columns::C_剤形].to_i,
                    full_name:       values[Treatment::Iyakuhin::Columns::C_基本漢字名称]
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
