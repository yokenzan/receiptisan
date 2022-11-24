# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 医療機関
        class Hospital
          # @param code [String] 医療機関コード
          # @param name [String] 医療機関名称
          # @param tel [String] 電話番号
          # @param prefecture [Prefecture] 都道府県
          # @param address [String, nil] 都道府県
          def initialize(code:, name:, tel:, prefecture:, address: nil)
            @code       = code
            @name       = name
            @tel        = tel
            @prefecture = prefecture
            @address    = address
          end

          # @!attribute [r] code
          #   @return [String] 医療機関コード
          # @!attribute [r] name
          #   @return [String] 医療機関名称
          # @!attribute [r] tel
          #   @return [String] 電話番号
          # @!attribute [r] prefecture
          #   @return [Prefecture] 所在都道府県
          # @!attribute [r] address
          #   @return [String, nil] 医療機関所在地
          attr_reader :code, :name, :tel, :prefecture, :address
        end
      end
    end
  end
end
