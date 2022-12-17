# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 性別(男女区分)
        class Sex
          SEX_MALE   = :'1'
          SEX_FEMALE = :'2'

          def initialize(code:, name:, short_name:)
            @code       = code
            @name       = name
            @short_name = short_name
          end

          # @!attribute [r] code
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] short_name
          #   @return [String]
          attr_reader :code, :name, :short_name

          @sexes = {
            SEX_MALE => new(code: SEX_MALE.to_s.to_i, name: '男性', short_name: '男'),
            SEX_FEMALE => new(code: SEX_FEMALE.to_s.to_i, name: '女性', short_name: '女'),
          }

          class << self
            # @param code [String, Integer]
            # @return [self, nil]
            def find_by_code(code)
              @sexes[code.to_s.intern]
            end
          end
        end
      end
    end
  end
end
