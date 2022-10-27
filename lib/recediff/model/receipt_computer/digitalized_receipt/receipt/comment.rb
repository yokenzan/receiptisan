# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # コメント
          class Comment
            # @param item [Master::Treatment::Comment]
            # @param shinryou_shikibetsu [ShinryouShikibetsu, nil]
            # @param futan_kubun [FutanKubun]
            # @param additional_text [String, nil]
            def initialize(
              item:,
              additional_text:,
              shinryou_shikibetsu:,
              futan_kubun:
            )
              @item                = item
              @additional_text     = additional_text
              @shinryou_shikibetsu = shinryou_shikibetsu
              @futan_kubun         = futan_kubun
            end

            def tensuu?
              false
            end

            def to_s
              item.format_with(additional_text)
            end

            # @!attribute [r] item
            #   @return [Master::Treatment::Comment]
            # @!attribute [r] additional_text
            #   @return [String, nil]
            # @!attribute [r] shinryou_shikibetsu
            #   @return [ShinryouShikibetsu, nil]
            # @!attribute [r] futan_kubun
            #   @return [FutanKubun]
            attr_reader :item, :additional_text, :shinryou_shikibetsu, :futan_kubun
          end
        end
      end
    end
  end
end
