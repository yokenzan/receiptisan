# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 審査支払機関
        class AuditPayer
          # 審査支払機関不明
          PAYER_CODE_UNKNOWN = 0
          # 支払基金
          PAYER_CODE_SHAHO   = 1
          # 国保連合会
          PAYER_CODE_KOKUHO  = 2

          def initialize(code:, name:, short_name:)
            @code       = code
            @name       = name
            @short_name = short_name
          end

          # @!attribute [r] code
          #   @return [Symbol] 審査支払機関コード
          # @!attribute [r] name
          #   @return [String] 名称
          # @!attribute [r] short_name
          #   @return [String] 略号
          attr_reader :code, :name, :short_name

          @payers = {
            PAYER_CODE_SHAHO => new(
              code:       PAYER_CODE_SHAHO.to_s.intern,
              name:       '社会保険診療報酬支払基金',
              short_name: '社'
            ),
            PAYER_CODE_KOKUHO => new(
              code:       PAYER_CODE_KOKUHO.to_s.intern,
              name:       '国民健康保険団体連合会',
              short_name: '国'
            ),
          }

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
