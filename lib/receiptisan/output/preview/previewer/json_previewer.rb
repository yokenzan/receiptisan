# frozen_string_literal: true

require 'json'

module Receiptisan
  module Output
    module Preview
      module Previewer
        class JSONPreviewer
          # @param digitalized_receipt [Parameter::Common::DigitalizedReceipt]
          # @return [String]
          def preview(digitalized_receipt)
            JSON.dump(to_h_recursively(digitalized_receipt))
          end

          def to_h_recursively(param)
            case param
            when Array
              param.map { | value | to_h_recursively(value) }
            when Struct, Hash
              param.to_h { | key, value | [key.to_s, to_h_recursively(value)] }
            when String
              param.to_s
            else
              param
            end
          end
        end
      end
    end
  end
end
