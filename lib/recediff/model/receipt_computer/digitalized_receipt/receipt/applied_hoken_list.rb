# frozen_string_literal: true

require 'forwardable'

module Recediff
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

            # @return [Array<IryouHoken, KouhiFutanIryou>]
            def to_a
              [iryou_hoken].concat(@kouhi_futan_iryous).compact
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

            # @!attribute [r] iryou_hoken
            #   @return [IryouHoken, nil]
            attr_reader :iryou_hoken
            # @!attribute [r] kouhi_futan_iryous
            #   @return [Array<KouhiFutanIryou>, nil]
            attr_reader :kouhi_futan_iryous

            def_delegators :to_a, :each, :map
          end
        end
      end
    end
  end
end
