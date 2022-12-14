# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          class Buffer
            extend Forwardable

            def initialize
              prepare
            end

            # @param digitalized_receipt [DigitalizedReceipt]
            # @return [void]
            def new_digitalized_receipt(digitalized_receipt)
              @digitalized_receipt = digitalized_receipt
            end

            # @param receipt [DigitalizedReceipt::Receipt]
            # @return [void]
            def new_receipt(receipt)
              fix_current_receipt

              @current_receipt             = receipt
              @current_receipt.hospital    = @digitalized_receipt.hospital
              @current_shinryou_shikibetsu = nil
              @current_hoken_list          = Receipt::AppliedHokenList.new
              @hoken_order_provider.clear
            end

            # @return [Month]
            def current_shinryou_ym
              @current_receipt.shinryou_ym
            end

            # @return [IryouHoken, nil]
            def current_iryou_hoken
              @current_hoken_list.iryou_hoken
            end

            # @return [AuditPayer nil]
            def current_audit_payer
              @digitalized_receipt.audit_payer
            end

            def nyuuin?
              @current_receipt.nyuuin?
            end

            # @param iryou_hoken [Receipt::IryouHoken]
            def add_iryou_hoken(iryou_hoken)
              @current_hoken_list.add(hoken_order_provider.provide_iryou_hoken, iryou_hoken)
            end

            # @param kouhi_futan_iryou [Receipt::KouhiFutanIryou]
            def add_kouhi_futan_iryou(kouhi_futan_iryou)
              @current_hoken_list.add(hoken_order_provider.provide_kouhi_futan_iryou, kouhi_futan_iryou)
            end

            # @param shoujou_shouki [Receipt::ShoujouShouki]
            # @return [void]
            def add_shoujou_shouki(shoujou_shouki)
              @current_receipt.add_shoujou_shouki(shoujou_shouki)
            end

            # @param tekiyou_item [Receipt::Tekiyou::Cost, Receipt::Tekiyou::Comment]
            def add_tekiyou(tekiyou_item)
              if (shinryou_shikibetsu = tekiyou_item.shinryou_shikibetsu)
                @current_shinryou_shikibetsu = shinryou_shikibetsu
                fix_current_santei_unit
                fix_current_ichiren_unit
                new_ichiren_unit(Receipt::Tekiyou::IchirenUnit.new(shinryou_shikibetsu: shinryou_shikibetsu))
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
              prepare
            end

            # @return [void]
            def prepare
              @hoken_order_provider        = HokenOrderProvider.new
              @digitalized_receipt         = nil
              @current_receipt             = nil
              @current_hoken_list          = nil
              @current_shinryou_shikibetsu = nil
              @latest_kyuufu_wariai        = nil
              @latest_teishotoku_type      = nil
              @previous_was_comment_item   = false
              @can_fix_current_santei_unit = false
            end

            # @return [DigitalizedReceipt]
            def close
              fix_current_receipt

              digitalized_receipt = @digitalized_receipt
              clear
              digitalized_receipt
            end

            def latest_kyuufu_wariai
              @latest_kyuufu_wariai.tap { @latest_kyuufu_wariai = nil }
            end

            def latest_teishotoku_type
              @latest_teishotoku_type.tap { @latest_teishotoku_type = nil }
            end

            attr_writer :latest_kyuufu_wariai
            attr_writer :latest_teishotoku_type

            def_delegators :current_receipt, :add_shoubyoumei

            private

            def fix_current_receipt
              return unless @current_receipt

              fix_current_santei_unit
              fix_current_ichiren_unit

              @digitalized_receipt.add_receipt(@current_receipt)
              @current_receipt.hoken_list = @current_hoken_list
              @current_receipt.fix!

              @current_receipt = nil
              @current_hoken_list = nil
            end

            def new_ichiren_unit(ichiren_unit)
              @current_ichiren_unit = ichiren_unit
            end

            def fix_current_ichiren_unit
              return unless @current_ichiren_unit

              @current_receipt.add_ichiren_unit(@current_ichiren_unit)
              @current_ichiren_unit = nil
            end

            def new_santei_unit
              @current_santei_unit = Receipt::Tekiyou::SanteiUnit.new
            end

            def fix_current_santei_unit
              return unless @current_santei_unit

              @current_santei_unit.fix!
              @current_ichiren_unit.add_santei_unit(@current_santei_unit)
              @current_santei_unit = nil
            end

            # @!attribute [r] current_receipt
            #   @return [DigitalizedReceipt::Receipt]
            # @!attribute [r] hoken_order_provider
            #   @return [HokenOrderProvider]
            attr_reader :current_receipt, :hoken_order_provider
          end
        end
      end
    end
  end
end
