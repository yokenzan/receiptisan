# frozen_string_literal: true

require 'erb'

module Receiptisan
  module Output
    module Preview
      module Previewer
        class SVGPreviewer
          # @param digitalized_receipt [Parameter::Common::DigitalizedReceipt]
          def preview(digitalized_receipt)
            preview_receipt(digitalized_receipt.receipts[5])
          end

          # @param digitalized_receipt [Parameter::Common::Receipt]
          def preview_receipt(receipt)
            puts ERB.new(File.read(__dir__ + '/../../../../../views/receipt/format-nyuuin-new.svg')).result(binding)
          end

          def to_zenkaku(number)
            number.to_s.tr('0-9.', '０-９．')
          end
        end
      end
    end
  end
end
