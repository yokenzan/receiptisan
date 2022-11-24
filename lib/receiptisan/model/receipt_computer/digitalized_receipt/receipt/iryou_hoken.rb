# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # 医療保険
          class IryouHoken
            extend Forwardable

            # rubocop:disable Metrics/ParameterLists
            def initialize(
              hokenja_bangou:,
              kigou:,
              bangou:,
              kyuufu_wariai:,
              teishotoku_kubun:,
              gemmen_kubun:,
              nissuu_kyuufu:
            )
              @hokenja_bangou   = hokenja_bangou
              @kigou            = kigou
              @bangou           = bangou
              @nissuu_kyuufu    = nissuu_kyuufu
              @teishotoku_kubun = teishotoku_kubun
              @gemmen_kubun     = gemmen_kubun
              @kyuufu_wariai    = kyuufu_wariai
              @edaban           = nil
            end
            # rubocop:enable Metrics/ParameterLists

            # @param edaban [String]
            # @return [void]
            def update_edaban(edaban)
              @edaban = edaban
            end

            # @!attribute [r] hokenja_bangou
            #   @return [string]
            attr_reader :hokenja_bangou
            # @!attribute [r] kigou
            #   @return [String, nil]
            attr_reader :kigou
            # @!attribute [r] bangou
            #   @return [String]
            attr_reader :bangou
            # @!attribute [r] kyuufu_wariai
            #   @return [Integer, nil]
            attr_reader :kyuufu_wariai
            # @!attribute [r] teishotoku_kubun
            #   @return [Integer, nil]
            attr_reader :teishotoku_kubun
            # @!attribute [r] gemmen_kubun
            #   @return [Integer]
            attr_reader :gemmen_kubun
            # @!attribute [r] edaban
            #   @return [String, nil]
            attr_reader :edaban

            def_delegators :@nissuu_kyuufu,
              :goukei_tensuu,
              :shinryou_jitsunissuu,
              :ichibu_futankin,
              :kyuufu_taishou_ichibu_futankin,
              :shokuji_seikatsu_ryouyou_kaisuu,
              :shokuji_seikatsu_ryouyou_goukei_kingaku
          end
        end
      end
    end
  end
end
