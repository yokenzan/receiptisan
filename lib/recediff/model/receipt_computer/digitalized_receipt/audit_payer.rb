# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 審査支払機関
        class AuditPayer
          PAYER_CODE_UNKNOWN = 0
          PAYER_CODE_SHAHO   = 1
          PAYER_CODE_KOKUHO  = 2

          def initialize(code:, name:, short_name:)
            @code       = code
            @name       = name
            @short_name = short_name
          end

          # @!attribute [r] code
          #   @return [Symbol]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] short_name
          #   @return [String]
          attr_reader :code, :name, :short_name

          # rubocop:disable Layout/HashAlignment, Layout/ExtraSpacing
          @payers = {
            PAYER_CODE_KOKUHO => new(code: PAYER_CODE_SHAHO.to_s.intern,  name: '社会保険診療報酬支払基金', short_name: '社'),
            PAYER_CODE_SHAHO  => new(code: PAYER_CODE_KOKUHO.to_s.intern, name: '国民健康保険団体連合会',   short_name: '国'),
          }
          # rubocop:enable Layout/HashAlignment, Layout/ExtraSpacing

          class << self
            # @param code [String, Integer]
            # @return [self, nil]
            def find_by_code(code)
              @payers[code.to_i]
            end
          end
        end
      end
    end
  end
end
