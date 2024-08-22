# frozen_string_literal: true

require 'json'

module Receiptisan
  module Output
    module Preview
      module Previewer
        class JSONPreviewer
          using Receiptisan::Util::RecursivelyHashConvertable

          # @param lib_version [String]
          # @param digitalized_receipts [Array<Parameter::Common::DigitalizedReceipt>]
          # @return [String]
          def preview(_lib_version, *digitalized_receipts)
            JSON.dump(digitalized_receipts.to_hash_recursively)
          end
        end
      end
    end
  end
end
