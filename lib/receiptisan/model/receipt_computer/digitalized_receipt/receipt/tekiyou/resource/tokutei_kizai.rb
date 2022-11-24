# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Resource
              class TokuteiKizai
                extend Forwardable

                def initialize(
                  master_item:,
                  shiyouryou:,
                  product_name:,
                  unit:,
                  unit_price:
                )
                  @master_item  = master_item
                  @shiyouryou   = shiyouryou
                  @product_name = product_name
                  @unit         = unit
                  @unit_price   = unit_price
                end

                # @return [Master::Unit, nil]
                def unit
                  @unit || master_item.unit
                end

                # @return [Float, nil]
                def unit_price
                  @unit_price || master_item.price
                end

                # @!attribute [r] master_item
                #   @return [Master::Treatment::TokuteiKizai]
                # @!attribute [r] shiyouryou
                #   @return [Float, nil]
                # @!attribute [r] product_name
                #   @return [String, nil]
                attr_reader :master_item, :shiyouryou, :product_name

                # @!attribute [r] code
                #   @return [Master::Treatment::TokuteiKizai::Code]
                # @!attribute [r] name
                #   @return [String]
                def_delegators :master_item, :code, :name, :price_type
              end
            end
          end
        end
      end
    end
  end
end
