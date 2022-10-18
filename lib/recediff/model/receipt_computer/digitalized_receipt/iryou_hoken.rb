# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class IryouHoken
          extend Forwardable

          def initialize(
            hokenja_bangou:,
            kigou:,
            bangou:,
            gemmen_kubun:,
            nissuu_kyuufu:
          )
            @hokenja_bangou = hokenja_bangou
            @kigou          = kigou
            @bangou         = bangou
            @gemmen_kubun   = gemmen_kubun
            @nissuu_kyuufu  = nissuu_kyuufu
            @edaban         = nil
          end

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
          # @!attribute [r] gemmen_kubun
          #   @return [Integer]
          attr_reader :gemmen_kubun
          # @!attribute [r] edaban
          #   @return [String, nil]
          attr_reader :edaban

          def_delegators :@nissuu_kyuufu,
            :goukei_tensuu,
            :shinryou_jitsunisuu,
            :ichibu_futankin,
            :kyuufu_taishou_ichibu_futankin,
            :shokuji_seikatsu_ryouyou_kaisuu,
            :shokuji_seikatsu_ryouyou_goukei_kingaku
        end
      end
    end
  end
end
