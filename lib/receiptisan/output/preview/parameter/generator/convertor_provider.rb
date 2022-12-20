# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        class Generator
          class ConvertorProvider
            Common             = Receiptisan::Output::Preview::Parameter::Common
            DigitalizedReceipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt

            class << self
              # DI container, withou you
              #
              # @return [TekiyouConvertor]
              def provide
                TekiyouConvertor.new(
                  TekiyouConvertor::IchirenUnitConvertor.new(
                    TekiyouConvertor::SanteiUnitConvertor.new(
                      TekiyouConvertor::TekiyouItemConvertor.new(
                        TekiyouConvertor::ResourceTextConvertor.new
                      )
                    )
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
