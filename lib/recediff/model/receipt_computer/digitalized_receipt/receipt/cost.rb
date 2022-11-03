# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          class Cost
            extend Forwardable

            # @param item [ShinryouKoui, Iyakuhin, TokuteiKizai]
            # @param shinryou_shikibetsu [ShinryouShikibetsu]
            # @param futan_kubun [FutanKubun]
            # @param tensuu [Integer, nil]
            # @param kaisuu [Integer, nil]
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
              @tensuu              = tensuu&.to_i
              @kaisuu              = kaisuu&.to_i
            end

            # @param comment [Comment]
            # @return [void]
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

            def tensuu?
              !@tensuu.nil?
            end

            def kaisuu?
              !@kaisuu.nil?
            end

            # @!attribute [r] item
            #   @return [ShinryouKoui, Iyakuhin, TokuteiKizai]
            # @!attribute [r] futan_kubun
            #   @return [FutanKubun]
            # @!attribute [r] tensuu
            #   @return [Integer, nil]
            # @!attribute [r] kaisuu
            #   @return [Integer, nil]
            # @!attribute [r] shinryou_shikibetsu
            #   @return [ShinryouShikibetsu]
            attr_reader :item, :futan_kubun, :tensuu, :kaisuu, :shinryou_shikibetsu

            def_delegators :item, :master_item, :code, :name

            private

            attr_reader :days
          end
        end
      end
    end
  end
end
