# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 医療機関
        class Hospital
          MIN_BED_COUNT_OF_HOSPITAL = 20

          # @param code [String] 医療機関コード
          # @param name [String] 医療機関名称
          # @param tel [String] 電話番号
          # @param prefecture [Prefecture] 都道府県
          # @param bed_count [Integer] 病床数
          # @param location [String, nil] 所在地
          def initialize(code:, name:, tel:, prefecture:, bed_count:, location:)
            @code       = code
            @name       = name
            @tel        = tel
            @prefecture = prefecture
            @bed_count  = bed_count
            @location   = location
          end

          def hospital?
            bed_count >= MIN_BED_COUNT_OF_HOSPITAL
          end

          # @!attribute [r] code
          #   @return [String] 医療機関コード
          # @!attribute [r] name
          #   @return [String] 医療機関名称
          # @!attribute [r] tel
          #   @return [String] 電話番号
          # @!attribute [r] prefecture
          #   @return [Prefecture] 所在都道府県
          # @!attribute [r] bed_count
          #   @return [Integer] 病床数
          # @!attribute [r] location
          #   @return [String, nil] 医療機関所在地
          attr_reader :code, :name, :tel, :prefecture, :bed_count, :location
        end
      end
    end
  end
end
