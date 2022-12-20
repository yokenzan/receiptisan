# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        class Generator
          class TekiyouConvertor
            class SanteiUnitConvertor
              Common             = Receiptisan::Output::Preview::Parameter::Common
              DigitalizedReceipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt

              def initialize(tekiyou_item_convertor)
                @tekiyou_item_convertor = tekiyou_item_convertor
              end

              # @param santei_unit [DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
              # @return [Common::SanteiUnit]
              def convert(santei_unit)
                parameterized_santei_unit = Common::SanteiUnit.new(
                  tensuu: santei_unit.tensuu,
                  kaisuu: santei_unit.kaisuu,
                  items:  []
                )

                santei_unit.each do | tekiyou_item |
                  parameterized_santei_unit.items << @tekiyou_item_convertor.convert(tekiyou_item)
                  next if tekiyou_item.comment?

                  tekiyou_item.each_comment do | comment |
                    parameterized_santei_unit.items << @tekiyou_item_convertor.convert(comment)
                  end
                end

                parameterized_santei_unit
              end
            end
          end
        end
      end
    end
  end
end
