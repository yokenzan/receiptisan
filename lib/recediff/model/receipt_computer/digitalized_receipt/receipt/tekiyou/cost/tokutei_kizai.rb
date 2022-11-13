# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Cost
              class TokuteiKizai
                extend Forwardable

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
                alias master_item master_tokutei_kizai

                def_delegators :master_item, :code, :name, :unit
              end
            end
          end
        end
      end
    end
  end
end
