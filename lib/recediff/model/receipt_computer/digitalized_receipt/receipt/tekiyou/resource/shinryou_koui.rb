# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Resource
              class ShinryouKoui
                extend Forwardable

                def initialize(master_item:, shiyouryou:)
                  @master_item = master_item
                  @shiyouryou  = shiyouryou
                end

                # @!attribute [r] master_item
                #   @return [Master::Treatment::ShinryouKoui]
                # @!attribute [r] shiyouryou
                #   @return [Integer, nil]
                attr_reader :master_item, :shiyouryou

                # @!attribute [r] code
                #   @return [Master::Treatment::ShinryouKoui::Code]
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
