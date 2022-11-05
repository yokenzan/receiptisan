# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Cost
              class TokuteiKizai
                def initialize(
                  master_tokutei_kizai:,
                  shiyouryou:,
                  product_name:
                )
                  @master_tokutei_kizai = master_tokutei_kizai
                  @shiyouryou           = shiyouryou
                  @product_name         = product_name
                end

                attr_reader :master_tokutei_kizai
                attr_reader :shiyouryou
                attr_reader :product_name
                alias_method :master_item, :master_tokutei_kizai
              end
            end
          end
        end
      end
    end
  end
end
