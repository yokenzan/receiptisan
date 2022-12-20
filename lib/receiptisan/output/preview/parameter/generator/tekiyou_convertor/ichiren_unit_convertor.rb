# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        class Generator
          class TekiyouConvertor
            class IchirenUnitConvertor
              Common             = Receiptisan::Output::Preview::Parameter::Common
              DigitalizedReceipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt

              def initialize(santei_unit_convertor)
                @santei_unit_convertor = santei_unit_convertor
              end

              # @param ichiren_unit [DigitalizedReceipt::Receipt::Tekiyou::IchirenUnit]
              # @return [Common::IchirenUnit]
              def convert(ichiren_unit)
                Common::IchirenUnit.new(
                  futan_kubun:  ichiren_unit.futan_kubun.code,
                  santei_units: ichiren_unit.map { | santei | @santei_unit_convertor.convert(santei) }
                )
              end
            end
          end
        end
      end
    end
  end
end
