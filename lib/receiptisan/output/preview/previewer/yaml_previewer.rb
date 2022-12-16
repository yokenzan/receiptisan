# frozen_string_literal: true

require 'yaml'

module Receiptisan
  module Output
    module Preview
      module Previewer
        class YAMLPreviewer
          using Receiptisan::Util::RecursivelyHashConvertable

          # @param digitalized_receipts [Array<Parameter::Common::DigitalizedReceipt>]
          # @return [String]
          def preview(*digitalized_receipts)
            YAML.dump(digitalized_receipts.to_hash_recursively)
          end
        end
      end
    end
  end
end
