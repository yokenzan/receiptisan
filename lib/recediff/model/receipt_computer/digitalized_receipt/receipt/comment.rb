# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # コメント
          class Comment
            def initialize(
              master_comment:,
              additional_text:,
              shinryou_shikibetsu:,
              futan_kubun:
            )
              @master_comment      = master_comment
              @additional_text     = additional_text
              @shinryou_shikibetsu = shinryou_shikibetsu
              @futan_kubun         = futan_kubun
            end

            attr_reader :master_comment, :additional_text, :shinryou_shikibetsu, :futan_kubun
            alias_method :item,        :master_comment
            alias_method :master_item, :master_comment
          end
        end
      end
    end
  end
end
