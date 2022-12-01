# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # 適用保険リスト
          class AppliedHokenList
            extend Forwardable

            def initialize
              @hokens_with_order = {}
            end

            # @param hoken_order [FutanKubun::HokenOrder]
            # @param hoken [Receipt::IryouHoken, Receipt::KouhiFutanIryou]
            # @return [void]
            def add(hoken_order, hoken)
              @hokens_with_order[hoken_order] = hoken
            end

            # @return [Receipt::IryouHoken, nil]
            def iryou_hoken
              @hokens_with_order[FutanKubun::HokenOrder.iryou_hoken]
            end

            # @return [Array<HokenWithOrder>]
            def kouhi_futan_iryous
              @hokens_with_order
                .dup.tap { | hash | hash.delete(FutanKubun::HokenOrder.iryou_hoken) }
            end

            def each_pair(&block)
              enum = @hokens_with_order.to_enum(:each)

              block_given? ? enum.each(&block) : enum
            end

            def each_hoken(&block)
              enum = @hokens_with_order.values.to_enum(:each)

              block_given? ? enum.each(&block) : enum
            end

            def each_order(&block)
              enum = @hokens_with_order.keys.to_enum(:each)

              block_given? ? enum.each(&block) : enum
            end
          end
        end
      end
    end
  end
end
