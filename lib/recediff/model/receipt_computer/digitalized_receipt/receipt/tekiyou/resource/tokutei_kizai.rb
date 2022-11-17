# frozen_string_literal: true

require 'forwardable'

module Recediff
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
                  product_name:
                )
                  @master_item  = master_item
                  @shiyouryou   = shiyouryou
                  @product_name = product_name
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
                # @!attribute [r] unit
                #   @return [Master::Unit, nil]
                def_delegators :master_item, :code, :name, :unit
              end
            end
          end
        end
      end
    end
  end
end
