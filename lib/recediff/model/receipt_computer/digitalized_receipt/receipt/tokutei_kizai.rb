# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          class TokuteiKizai
            def initialize(
              master_tokutei_kizai:,
              shiyouryou:,
              # tanka:,
              product_name:
            )
              @master_tokutei_kizai = master_tokutei_kizai
              @shiyouryou           = shiyouryou
              # @tanka                = tanka
              @product_name         = product_name
            end

            attr_reader :master_tokutei_kizai
            attr_reader :shiyouryou
            # attr_reader :tanka
            attr_reader :product_name
            alias_method :master_item, :master_tokutei_kizai
          end
        end
      end
    end
  end
end
