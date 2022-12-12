# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Abbrev
        # @!attribute [r] label 表示名
        #   @return [String, nil]
        # @!attribute [r] code 診療行為コードの配列
        #   @return [Array<Symbol>]
        Abbrev = Struct.new(:label, :code, keyword_init: true) do
          class << self
            # @return [self]
            # yaml上のindexは記載要領との突合の便宜を図ったものなので、プログラム上は読み飛ばす
            def from(definition)
              new(label: definition['label'], code: definition['code'].to_s.intern)
            end
          end
        end
      end
    end
  end
end
