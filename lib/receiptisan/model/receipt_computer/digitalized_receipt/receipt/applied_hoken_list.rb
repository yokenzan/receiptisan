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
              @iryou_hoken        = nil
              @kouhi_futan_iryous = []
            end

            # @param iryou_hoken [IryouHoken]
            # @return [void]
            def add_iryou_hoken(iryou_hoken)
              @iryou_hoken = iryou_hoken
            end

            # @param kouhi_futan_iryou [KouhiFutanIryou]
            # @return [void]
            def add_kouhi_futan_iryou(kouhi_futan_iryou)
              @kouhi_futan_iryous << kouhi_futan_iryou
            end

            def each(&block)
              list = {}

              list[FutanKubun::HokenOrder.iryou_hoken] = iryou_hoken if iryou_hoken

              kouhi_futan_iryous.each_with_index do | kouhi_futan_iryou, index |
                list[FutanKubun::HokenOrder.kouhi_futan_iryou(index)] = kouhi_futan_iryou
              end

              enum = list.to_enum(:each)

              block_given? ? enum.each(&block) : enum
            end

            # @return [Array<FutanKubun::HokenOrder>]
            def to_hoken_orders
              orders = []
              orders << FutanKubun::HokenOrder.iryou_hoken if iryou_hoken
              kouhi_futan_iryous.each_index { | index | orders << FutanKubun::HokenOrder.kouhi_futan_iryou(index) }

              orders
            end

            # @!attribute [r] iryou_hoken
            #   @return [IryouHoken, nil]
            attr_reader :iryou_hoken
            # @!attribute [r] kouhi_futan_iryous
            #   @return [Array<KouhiFutanIryou>]
            attr_reader :kouhi_futan_iryous
          end
        end
      end
    end
  end
end
