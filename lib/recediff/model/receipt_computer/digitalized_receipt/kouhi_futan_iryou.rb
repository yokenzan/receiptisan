# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 公費負担医療
        class KouhiFutanIryou
          extend Forwardable

          def initialize(futansha_bangou:, jukyuusha_bangou:, nissuu_kyuufu:)
            @futansha_bangou  = futansha_bangou
            @jukyuusha_bangou = jukyuusha_bangou
            @nissuu_kyuufu    = nissuu_kyuufu
          end

          # @!attribute [r] futansha_bangou
          #   @return [string]
          attr_reader :futansha_bangou
          # @!attribute [r] jukyuusha_bangou
          #   @return [string]
          attr_reader :jukyuusha_bangou
          # @!attribute [r] nissuu_kyuufu
          #   @return [NissuuKyuufu]
          attr_reader :nissuu_kyuufu

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
