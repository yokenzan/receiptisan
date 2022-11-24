# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          class ReceiptTypeBuilder
            ReceiptType = DigitalizedReceipt::Receipt::Type

            # rubocop:disable Layout/HashAlignment
            def initialize
              @main_hoken_types = {
                '1': {
                  DigitalizedReceipt::AuditPayer::PAYER_CODE_UNKNOWN =>
                    ReceiptType::MainHokenType.new(code: 1, name: '国保・社保'),
                  DigitalizedReceipt::AuditPayer::PAYER_CODE_SHAHO   =>
                    ReceiptType::MainHokenType.new(code: 1, name: '社保'),
                  DigitalizedReceipt::AuditPayer::PAYER_CODE_KOKUHO  =>
                    ReceiptType::MainHokenType.new(code: 1, name: '国保'),
                },
                '2': ReceiptType::MainHokenType.new(code: 2, name: '公費'),
                '3': ReceiptType::MainHokenType.new(code: 3, name: '後期'),
                '4': ReceiptType::MainHokenType.new(code: 4, name: '退職'),
              }.tap { | types | types.each(&:freeze).freeze }

              clear
            end
            # rubocop:enable Layout/HashAlignment

            def clear
              @audit_payer        = nil
              @combined_type_code = nil
            end

            def build_with(combined_type_code)
              @combined_type_code = combined_type_code

              build
            end

            def build
              raise StandardError unless @combined_type_code

              ReceiptType.new(
                ReceiptType::TensuuHyouType.find_by_code(@combined_type_code[0]),
                detect_main_hoken_type(@combined_type_code[1]),
                ReceiptType::HokenMultipleType.find_by_code(@combined_type_code[2]),
                ReceiptType::PatientAgeType.find_by_code(@combined_type_code[3])
              ).tap { clear }
            end

            attr_writer :audit_payer, :combined_type_code

            private

            def detect_main_hoken_type(code)
              type = @main_hoken_types[code.to_s.intern]
              type.is_a?(ReceiptType::MainHokenType) ? type : type[@audit_payer.code.to_s.to_i]
            end
          end
        end
      end
    end
  end
end
