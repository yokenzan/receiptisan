# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Resource
              class Iyakuhin
                extend Forwardable

                def initialize(master_item:, shiyouryou:)
                  @master_item = master_item
                  @shiyouryou  = shiyouryou
                end

                # @!attribute [r] master_item
                #   @return [Master::Treatment::Iyakuhin]
                # @!attribute [r] shiyouryou
                #   @return [Float, nil]
                attr_reader :master_item, :shiyouryou

                # @!attribute [r] code
                #   @return [Master::Treatment::Iyakuhin::Code]
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
