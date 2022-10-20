# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          class ShinryouKoui
            def initialize(master_shinryou_koui:, shiyouryou:)
              @master_shinryou_koui = master_shinryou_koui
              @shiyouryou           = shiyouryou
            end

            attr_reader :master_shinryou_koui, :shiyouryou
            alias_method :master_item, :master_shinryou_koui
          end
        end
      end
    end
  end
end
