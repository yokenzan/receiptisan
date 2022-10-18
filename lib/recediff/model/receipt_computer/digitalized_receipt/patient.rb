# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 患者
        class Patient
          # @param id [String]
          # @param name [String]
          # @param name_kana [String]
          # @param sex [Sex]
          # @param birth_date [Date]
          def initialize(id:, name:, name_kana:, sex:, birth_date:)
            @id         = id
            @name       = name
            @name_kana  = name_kana
            @sex        = sex
            @birth_date = birth_date
          end

          # @!attribute [r] id
          #   @return [String, Integer, nil]
          attr_reader :id
          # @!attribute [r] name
          #   @return [String]
          attr_reader :name
          # @!attribute [r] sex
          #   @return [Sex]
          attr_reader :sex
          # @!attribute [r] name_kana
          #   @return [String?]
          attr_reader :name_kana
          # @!attribute [r] birth_date
          # @return [Date]
          attr_reader :birth_date
        end
      end
    end
  end
end
