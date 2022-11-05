# frozen_string_literal: true

require 'forwardable'

require_relative 'cost/shinryou_koui'
require_relative 'cost/iyakuhin'
require_relative 'cost/tokutei_kizai'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
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

              def has_comments? # rubocop:disable Naming/PredicateName
                !@comments.empty?
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

              def done_at_breakdown; end

              def kaisuu_at_breakdown; end

              def tensuu?
                !@tensuu.nil?
              end

              def kaisuu?
                !@kaisuu.nil?
              end

              def comment?
                false
              end

              def to_s
                @item.to_s
              end

              def type
                case @item
                when ShinryouKoui
                  :SI
                when Iyakuhin
                  :IY
                else
                  :TO
                end
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

              def_delegators :item, :master_item, :code, :name, :shiyouryou, :unit

              private

              attr_reader :days
            end
          end
        end
      end
    end
  end
end
