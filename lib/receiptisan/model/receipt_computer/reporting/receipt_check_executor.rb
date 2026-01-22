# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        class ReceiptCheckExecutor
          def initialize
            @check_rules = []
          end

          def add_rule(rule)
            @check_rules << rule
          end

          def any_rules?
            @check_rules.empty?.!
          end

          def check(digitalized_receipt)
            reports = []

            @check_rules.each do | rule |
              reports << rule.check(digitalized_receipt)
            end

            reports.reject(&:empty?).join("\n")
          end
        end
      end
    end
  end
end
