# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          class HokenOrderProvider
            HokenOrder = ReceiptComputer::DigitalizedReceipt::Receipt::FutanKubun::HokenOrder

            IRYOU_HOKEN        = [HokenOrder.find_by_code(HokenOrder::HOKEN_ORDER_IRYOU_HOKEN)].freeze
            KOUHI_FUTAN_IRYOUS = [
              HokenOrder.find_by_code(HokenOrder::HOKEN_ORDER_KOUHI_1),
              HokenOrder.find_by_code(HokenOrder::HOKEN_ORDER_KOUHI_2),
              HokenOrder.find_by_code(HokenOrder::HOKEN_ORDER_KOUHI_3),
              HokenOrder.find_by_code(HokenOrder::HOKEN_ORDER_KOUHI_4),
            ].freeze

            def initialize
              clear
            end

            # @return [void]
            def clear
              @iryou_hoken        = IRYOU_HOKEN.dup
              @kouhi_futan_iryous = KOUHI_FUTAN_IRYOUS.dup
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
