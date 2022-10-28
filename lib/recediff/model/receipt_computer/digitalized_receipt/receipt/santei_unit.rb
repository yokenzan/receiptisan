# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # 点数・回数算定単位
          class SanteiUnit
            def initialize
              # @type tensuu [Integer, nil]
              @tensuu = nil
              # @type kaisuu [Integer, nil]
              @kaisuu = nil
              # @type items [Array<Cost, Comment>]
              @items  = []
            end

            # @param tekiyou_item [Cost, Comment]
            # @return [void]
            def add_tekiyou(tekiyou_item)
              @items << tekiyou_item
            end

            # @return [FutanKubun]
            def futan_kubun
              @items.first.futan_kubun
            end

            # @return [void]
            def fix
              @tensuu = @items.reverse.find(&:tensuu?)&.tensuu
            end

            # @!attribute [r] tensuu
            #   @return [Integer, nil]
            # @!attribute [r] kaisuu
            #   @return [Integer, nil]
            attr_writer :tensuu, :kaisuu
          end
        end
      end
    end
  end
end
