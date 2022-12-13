# frozen_string_literal: true

require 'yaml'

module Receiptisan
  module Output
    module Preview
      module Previewer
        class YAMLPreviewer
          using Receiptisan::Util::RecursivelyHashConvertable

          # @param digitalized_receipt [Parameter::Common::DigitalizedReceipt]
          # @return [String]
          def preview(digitalized_receipt)
            YAML.dump(digitalized_receipt.to_hash_recursively)
          end
        end
      end
    end
  end
end
