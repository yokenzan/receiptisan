# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # 負担区分
          class FutanKubun
            def initialize(code:)
              @code = code
            end

            # @!attribute [r] code
            #   @return [String]
            attr_reader :code
          end
        end
      end
    end
  end
end
