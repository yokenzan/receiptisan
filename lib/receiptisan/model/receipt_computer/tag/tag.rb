# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Tag
        # @!attribute [r] key タグの識別キー
        #   @return [String]
        # @!attribute [r] label 表示名
        #   @return [String, nil]
        # @!attribute [r] shinryou_shikibetsu 診療識別の配列
        #   @return [Array<String>]
        # @!attribute [r] code 診療行為・医薬品・特定器材のレセ電コードの配列
        #   @return [Array<Symbol>]
        # @!attribute [r] forbidden_code 含んでいてはならない診療行為・医薬品・特定器材のレセ電コードの配列
        #   @return [Array<Symbol>]
        Tag = Struct.new(:key, :label, :shinryou_shikibetsu, :code, :forbidden_code, keyword_init: true) do
          class << self
            # @return [self]
            def from(definition)
              new(
                key:                 definition['key'].intern,
                label:               definition['label'],
                shinryou_shikibetsu: definition['shinryou_shikibetsu'],
                code:                definition['code'].map { | code | code.to_s.intern },
                forbidden_code:      definition['forbidden_code']&.map { | code | code.to_s.intern } || []
              )
            end
          end
        end
      end
    end
  end
end
