# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Tag
        # @!attribute [r] name タグの識別キー
        #   @return [String]
        # @!attribute [r] label 表示名
        #   @return [String, nil]
        # @!attribute [r] shinryou_shikibetsu 診療識別の配列
        #   @return [Array<String>]
        # @!attribute [r] code 診療行為・医薬品・特定器材のレセ電コードの配列
        #   @return [Array<Symbol>]
        Tag = Struct.new(:name, :label, :shinryou_shikibetsu, :code, keyword_init: true) do
          class << self
            # @return [self]
            def from(definition)
              new(
                name:                definition['name'].intern,
                label:               definition['label'],
                shinryou_shikibetsu: definition['shinryou_shikibetsu'],
                code:                definition['code'].map { | code | code.to_s.intern }
              )
            end
          end
        end
      end
    end
  end
end
