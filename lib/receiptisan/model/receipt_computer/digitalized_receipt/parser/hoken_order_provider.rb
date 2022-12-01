# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          class HokenOrderProvider
            HokenOrder = ReceiptComputer::DigitalizedReceipt::Receipt::FutanKubun::HokenOrder

            @@iryou_hoken        = [HokenOrder.find_by_code(HokenOrder::HOKEN_ORDER_IRYOU_HOKEN)]
            @@kouhi_futan_iryous = [
              HokenOrder.find_by_code(HokenOrder::HOKEN_ORDER_KOUHI_1),
              HokenOrder.find_by_code(HokenOrder::HOKEN_ORDER_KOUHI_2),
              HokenOrder.find_by_code(HokenOrder::HOKEN_ORDER_KOUHI_3),
              HokenOrder.find_by_code(HokenOrder::HOKEN_ORDER_KOUHI_4),
            ]

            def initialize
              clear
            end

            # @return [void]
            def clear
              @iryou_hoken        = @@iryou_hoken.dup
              @kouhi_futan_iryous = @@kouhi_futan_iryous.dup
            end

            # @return [HokenOrder, nil]
            def provide_iryou_hoken
              @iryou_hoken.shift
            end

            # @return [HokenOrder, nil]
            def provide_kouhi_futan_iryou
              @kouhi_futan_iryous.shift
            end
          end
        end
      end
    end
  end
end
