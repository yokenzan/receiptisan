# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        # 標準負担額の集計
        class HyoujunFutangakuCalculator
          EnumeratorGenerator = Receiptisan::Model::ReceiptComputer::Util::ReceiptEnumeratorGenerator
          DigitalizedReceipt  = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt
          HokenOrder          = DigitalizedReceipt::Receipt::FutanKubun::HokenOrder
          TAG_KEYS            = %w[hyoujun-futangaku].freeze

          # @param tag_handler [Receiptisan::Model::ReceiptComputer::Tag::Handler]
          def initialize(tag_handler)
            @tag_handler = tag_handler
            @tags        = []
          end

          # @param receipt [DigitalizedReceipt::Receipt]
          def calculate(receipt)
            initialize_tags(receipt.shinryou_ym)

            hoken_orders = HokenOrder.each_hoken_order.to_h { | hoken_order_code, _ | [hoken_order_code, 0] }

            # @param tag [Receiptisan::Model::ReceiptComputer::Tag::Tag]
            @tags.each do | tag |
              # @param santei_unit [DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
              EnumeratorGenerator.each_santei_unit(receipt, *tag.shinryou_shikibetsu).map do | santei_unit |
                next unless santei_unit.resource_type == :shinryou_koui
                # @param cost [DigitalizedReceipt::Receipt::Tekiyou::Cost]
                next unless santei_unit.each_cost.any? { | cost | tag.code.include?(cost.resource.code.value) }

                # @param hoken_order [HokenOrder]
                HokenOrder.each_hoken_order do | code, hoken_order |
                  hoken_orders[code] += santei_unit.calculate if santei_unit.uses?(hoken_order)
                end
              end
            end

            hoken_orders
          end

          # @param year_month [Month]
          def initialize_tags(year_month)
            tag_handler.prepare(year_month)
            @tags = TAG_KEYS.map { | tag_key | tag_handler.find_by_key(tag_key) }
          end

          private

          # @!attribute [r] tag_handler
          #   @return [Receiptisan::Model::ReceiptComputer::Tag::Handler]
          attr_reader :tag_handler
        end
      end
    end
  end
end

