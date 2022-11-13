# frozen_string_literal: true

require 'forwardable'
require_relative 'digitalized_receipt/prefecture'
require_relative 'digitalized_receipt/audit_payer'
require_relative 'digitalized_receipt/hospital'
require_relative 'digitalized_receipt/sex'
require_relative 'digitalized_receipt/receipt'
require_relative 'digitalized_receipt/record'
require_relative 'digitalized_receipt/parser'

module Recediff
  module Model
    module ReceiptComputer
      # 電子レセプト(RECEIPTC.UKE)
      # 診療報酬請求書
      class DigitalizedReceipt
        extend Forwardable

        # @param seikyuu_ym [Month]
        # @param audit_payer [AuditPayer]
        # @param hospital [Hospital]
        def initialize(seikyuu_ym:, audit_payer:, hospital:)
          @seikyuu_ym  = seikyuu_ym
          @audit_payer = audit_payer
          @hospital    = hospital
          @receipts    = []
        end

        # @param receipt [Receipt]
        # @return nil
        def add_receipt(receipt)
          @receipts << receipt
          # @receipts[receipt.id] = receipt
        end

        # @!attribute [r] seikyuu_ym
        #   @return [Month]
        # @!attribute [r] audit_payer
        #   @return [AuditPayer]
        # @!attribute [r] hospital
        #   @return [Hospital]
        attr_reader :seikyuu_ym, :audit_payer, :hospital

        def_delegators :@receipts, :each, :each_with_index, :map, :to_a, :[]
      end
    end
  end
end
