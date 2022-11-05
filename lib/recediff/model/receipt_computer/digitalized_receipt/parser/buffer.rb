# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          class Buffer
            extend Forwardable

            def initialize
              clear
            end

            # @param digitalized_receipt [DigitalizedReceipt]
            # @return [void]
            def new_digitalized_receipt(digitalized_receipt)
              @digitalized_receipt = digitalized_receipt
            end

            # @param receipt [DigitalizedReceipt::Receipt]
            # @return [void]
            def new_receipt(receipt)
              @digitalized_receipt.add_receipt(@current_receipt) if @current_receipt
              @current_receipt             = receipt
              @current_receipt.hospital    = @digitalized_receipt.hospital
              @current_shinryou_shikibetsu = nil
            end

            # @return [Month]
            def current_shinryou_ym
              @current_receipt.shinryou_ym
            end

            # @return [IryouHoken, nil]
            def current_iryou_hoken
              @current_receipt.iryou_hoken
            end

            def nyuuin?
              @current_receipt.nyuuin?
            end

            # @param shoujou_shouki [ShoujouShouki]
            # @return [void]
            def add_shoujou_shouki(shoujou_shouki)
              @current_receipt.add_shoujou_shouki(shoujou_shouki)
            end

            # @param tekiyou_item [Receipt::Cost, Receipt::Comment]
            def add_tekiyou(tekiyou_item)
              if (shinryou_shikibetsu = tekiyou_item.shinryou_shikibetsu)
                @current_shinryou_shikibetsu = shinryou_shikibetsu
                fix_current_santei_unit
                fix_current_ichiren_unit
                new_ichiren_unit(Receipt::IchirenUnit.new(shinryou_shikibetsu: shinryou_shikibetsu))
                new_santei_unit
                @can_fix_current_santei_unit = false
              end

              if @can_fix_current_santei_unit && !tekiyou_item.comment?
                fix_current_santei_unit
                new_santei_unit
                @can_fix_current_santei_unit = false
              end

              @current_santei_unit.add_tekiyou(tekiyou_item)

              @can_fix_current_santei_unit = true if tekiyou_item.tensuu?
            end

            # @return [void]
            def clear
              @digitalized_receipt         = nil
              @current_receipt             = nil
              @current_shinryou_shikibetsu = nil
              @previous_was_comment_item   = false
              @can_fix_current_santei_unit = false
            end

            # @return [DigitalizedReceipt]
            def close
              fix_current_santei_unit
              fix_current_ichiren_unit

              digitalized_receipt = @digitalized_receipt
              clear
              digitalized_receipt
            end

            # @!attribute [r] current_receipt
            #   @return [DigitalizedReceipt::Receipt]
            attr_reader :current_receipt

            def_delegators :current_receipt,
              :add_shoubyoumei,
              :add_iryou_hoken,
              :add_kouhi_futan_iryou

            private

            def new_ichiren_unit(ichiren_unit)
              @current_ichiren_unit = ichiren_unit
            end

            def fix_current_ichiren_unit
              return unless @current_ichiren_unit

              @current_ichiren_unit.fix
              @current_receipt.add_ichiren_unit(@current_ichiren_unit)
              @current_ichiren_unit = nil
            end

            def new_santei_unit
              @current_santei_unit = Receipt::SanteiUnit.new
            end

            def fix_current_santei_unit
              return unless @current_santei_unit

              @current_santei_unit.fix
              @current_ichiren_unit.add_santei_unit(@current_santei_unit)
              @current_santei_unit = nil
            end
          end
        end
      end
    end
  end
end
