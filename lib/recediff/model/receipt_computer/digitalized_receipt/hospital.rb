# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 医療機関
        class Hospital
          # @param code [String]
          # @param prefecture [Prefecture]
          # @param name [String]
          # @param tel [String]
          def initialize(code:, name:, tel:, prefecture:)
            @code       = code
            @name       = name
            @tel        = tel
            @prefecture = prefecture
          end

          # @!attribute [r] code
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] tel
          #   @return [String]
          # @!attribute [r] prefecture
          #   @return [Prefecture]
          attr_reader :code, :name, :tel, :prefecture
        end
      end
    end
  end
end
