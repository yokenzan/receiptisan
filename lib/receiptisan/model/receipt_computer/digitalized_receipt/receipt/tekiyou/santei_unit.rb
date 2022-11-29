# frozen_string_literal: true

require 'forwardable'

module Receiptisan
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
                @tensuu        = nil
                # @type kaisuu [Integer, nil]
                @kaisuu        = nil
                # @type tekiyou_items [Array<Cost, Comment>]
                @tekiyou_items = []
              end

              # @param tekiyou_item [Cost, Comment]
              # @return [void]
              def add_tekiyou(tekiyou_item)
                @tekiyou_items << tekiyou_item
              end

              # @return [FutanKubun]
              def futan_kubun
                @tekiyou_items.first.futan_kubun
              end

              # @return [void]
              def fix!
                bottom_cost = @tekiyou_items.reverse.find(&:tensuu?)
                return unless bottom_cost

                @tensuu = bottom_cost.tensuu
                @kaisuu = bottom_cost.kaisuu
              end

              # @return [Symbol, nil] returns nil when only costists of comments.
              def resource_type
                tekiyou_items.find { | tekiyou_item | !tekiyou_item.comment? }&.resource_type
              end

              # @!attribute [r] tensuu
              #   @return [Integer, nil]
              # @!attribute [r] kaisuu
              #   @return [Integer, nil]
              attr_reader :tensuu, :kaisuu

              def_delegators :@tekiyou_items, :each, :map
            end
          end
        end
      end
    end
  end
end
