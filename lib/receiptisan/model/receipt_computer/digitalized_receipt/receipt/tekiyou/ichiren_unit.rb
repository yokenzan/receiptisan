# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            # 一連の行為単位
            #
            # - 診療識別11～14は「一連の行為単位 = 算定単位」を守る必要がある
            # - 画像診断は、一連の行為単位のなかに複数の算定単位をもつことが多い
            # - レセプト上、アスタリスクは一連ごとに付与する
            class IchirenUnit
              extend Forwardable

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

              # @return [self, nil]
              def on_date(date)
                return nil unless @santei_units.any? { | santei | santei.on_date?(date) }

                copied = self.class.new(shinryou_shikibetsu: shinryou_shikibetsu)

                @santei_units.each do | santei |
                  if new_santei = santei.on_date(date)
                    copied.add_santei_unit(new_santei)
                  end
                end

                copied.empty? ? nil : copied
              end

              # @!attribute [r] shinryou_shikibetsu
              #   @return [ShinryouShikibetsu]
              attr_reader :shinryou_shikibetsu

              def_delegators :@santei_units, :each, :map, :empty?
            end
          end
        end
      end
    end
  end
end
