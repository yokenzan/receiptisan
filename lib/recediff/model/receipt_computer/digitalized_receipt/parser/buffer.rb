# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          class Buffer
            def initialize
              clear
            end

            # @param digitalized_receipt [DigitalizedReceipt]
            # @return [void]
            def new_digitalized_receipt(digitalized_receipt)
              @digitalized_receipt = digitalized_receipt
            end

            # @param receipt [DigitalizedReceipt::Receipt]
            # @return [void]
            def new_receipt(receipt)
              @digitalized_receipt.add_receipt(@current_receipt) if @current_receipt
              @current_receipt = receipt
            end

            # @return [self]
            def clear
              @digitalized_receipt = nil
              @current_receipt     = nil
            end

            def close
              digitalized_receipt = @digitalized_receipt
              clear
              digitalized_receipt
            end

            # @!attribute [r]
            #   @return [DigitalizedReceipt::Receipt]
            attr_reader :current_receipt
          end
        end
      end
    end
  end
end
