# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          class Iyakuhin
            def initialize(master_iyakuhin:, shiyouryou:)
              @master_iyakuhin = master_iyakuhin
              @shiyouryou      = shiyouryou
            end

            attr_reader :master_iyakuhin, :shiyouryou
            alias_method :master_item, :master_iyakuhin
          end
        end
      end
    end
  end
end
