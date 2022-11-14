# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 性別(男女区分)
        class Sex
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
            '1': new(code: 1, name: '男性', short_name: '男'),
            '2': new(code: 2, name: '女性', short_name: '女'),
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
