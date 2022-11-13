# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            # 点数・回数算定単位
            class SanteiUnit
              extend Forwardable

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
                @kaisuu = @items.reverse.find(&:kaisuu?)&.kaisuu
              end

              # @!attribute [r] tensuu
              #   @return [Integer, nil]
              # @!attribute [r] kaisuu
              #   @return [Integer, nil]
              attr_reader :tensuu, :kaisuu

              def_delegators :@items, :each, :map
            end
          end
        end
      end
    end
  end
end
