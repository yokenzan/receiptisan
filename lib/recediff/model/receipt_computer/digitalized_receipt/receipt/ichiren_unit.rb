# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # 一連の行為単位
          #
          # - 診療識別11～14は「一連の行為単位 = 算定単位」を守る必要がある
          # - 画像診断は、一連の行為単位のなかに複数の算定単位をもつことが多い
          class IchirenUnit
            # @param shinryou_shikibetsu [ShinryouShikibetsu]
            def initialize(shinryou_shikibetsu:)
              @shinryou_shikibetsu = shinryou_shikibetsu
              # @type [Array<SanteiUnit>]
              @santei_units        = []
            end

            # @param santei_unit [SanteiUnit]
            # @return [void]
            def add_santei_unit(santei_unit)
              @santei_units << santei_unit
            end

            # @return [FutanKubun]
            def futan_kubun
              @santei_units.first.futan_kubun
            end

            # @return [void]
            def fix; end

            # @!attribute [r] shinryou_shikibetsu
            #   @return [ShinryouShikibetsu]
            attr_reader :shinryou_shikibetsu
          end
        end
      end
    end
  end
end
