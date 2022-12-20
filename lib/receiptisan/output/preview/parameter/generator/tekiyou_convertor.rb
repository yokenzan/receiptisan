# frozen_string_literal: true

require_relative 'tekiyou_convertor/resource_text_convertor'
require_relative 'tekiyou_convertor/tekiyou_item_convertor'
require_relative 'tekiyou_convertor/santei_unit_convertor'
require_relative 'tekiyou_convertor/ichiren_unit_convertor'

module Receiptisan
  module Output
    module Preview
      module Parameter
        class Generator
          class TekiyouConvertor
            Common             = Receiptisan::Output::Preview::Parameter::Common
            DigitalizedReceipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt

            def initialize(ichiren_unit_convertor)
              @ichiren_unit_convertor = ichiren_unit_convertor
            end

            # @param receipt [DigitalizedReceipt::Receipt]
            def convert(receipt)
              Common::Tekiyou.new(
                shinryou_shikibetsu_sections: receipt.map do | _, ichiren_units |
                  Common::ShinryouShikibetsuSection.new(
                    shinryou_shikibetsu: Common::ShinryouShikibetsu.from(ichiren_units.first.shinryou_shikibetsu),
                    ichiren_units:       ichiren_units.map { | ichiren | @ichiren_unit_convertor.convert(ichiren) }
                  )
                end.sort_by { | section | section.shinryou_shikibetsu.code }
              )
            end
          end
        end
      end
    end
  end
end
