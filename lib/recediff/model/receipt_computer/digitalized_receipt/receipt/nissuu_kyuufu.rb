# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # 日数・給付
          class NissuuKyuufu
            def initialize(
              goukei_tensuu:,
              shinryou_jitsunissuu:,
              ichibu_futankin:,
              kyuufu_taishou_ichibu_futankin:,
              shokuji_seikatsu_ryouyou_kaisuu:,
              shokuji_seikatsu_ryouyou_goukei_kingaku:
            )
              @goukei_tensuu                           = goukei_tensuu
              @shinryou_jitsunissuu                    = shinryou_jitsunissuu
              @ichibu_futankin                         = ichibu_futankin
              @kyuufu_taishou_ichibu_futankin          = kyuufu_taishou_ichibu_futankin
              @shokuji_seikatsu_ryouyou_kaisuu         = shokuji_seikatsu_ryouyou_kaisuu
              @shokuji_seikatsu_ryouyou_goukei_kingaku = shokuji_seikatsu_ryouyou_goukei_kingaku
            end

            # @!attribute [r] goukei_tensuu
            #   @return [Integer]
            attr_reader :goukei_tensuu
            # @!attribute [r] shinryou_jitsunissuu
            #   @return [Integer]
            attr_reader :shinryou_jitsunissuu
            # @!attribute [r] ichibu_futankin
            #   @return [Integer, nil]
            attr_reader :ichibu_futankin
            # @!attribute [r] kyuufu_taishou_ichibu_futankin
            #   @return [Integer, nil]
            attr_reader :kyuufu_taishou_ichibu_futankin
            # @!attribute [r] shokuji_seikatsu_ryouyou_kaisuu
            #   @return [Integer, nil]
            attr_reader :shokuji_seikatsu_ryouyou_kaisuu
            # @!attribute [r] shokuji_seikatsu_ryouyou_goukei_kingaku
            #   @return [Integer, nil]
            attr_reader :shokuji_seikatsu_ryouyou_goukei_kingaku
          end
        end
      end
    end
  end
end
