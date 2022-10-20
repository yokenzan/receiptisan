# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Cost
          extend Forwardable

          def initialize(
            item:,
            shinryou_shikibetsu:,
            futan_kubun:,
            tensuu:,
            kaisuu:
          )
            @item                = item
            @shinryou_shikibetsu = shinryou_shikibetsu
            @futan_kubun         = futan_kubun
            @tensuu              = tensuu
            @kaisuu              = kaisuu
          end

          def add_comment(comment)
            @comments << comment
          end

          # @param day [Integer]
          # @return [Integer]
          def kaisuu_at(day)
            days[day - 1].to_i
          end

          # @param day [Integer]
          # @return [Boolean]
          def done_at?(day)
            kaisuu_at(day).positive?
          end


          attr_reader :item, :futan_kubun, :tensuu, :kaisuu, :shinryou_shikibetsu

          def_delegators :item, :master_item

          private

          attr_reader :days
        end
      end
    end
  end
end
