# frozen_string_literal: true

require 'forwardable'
require_relative 'digitalized_receipt/prefecture'
require_relative 'digitalized_receipt/audit_payer'
require_relative 'digitalized_receipt/byoushou_type'
require_relative 'digitalized_receipt/hospital'
require_relative 'digitalized_receipt/sex'
require_relative 'digitalized_receipt/receipt'
require_relative 'digitalized_receipt/record'
require_relative 'digitalized_receipt/parser'

module Receiptisan
  module Model
    module ReceiptComputer
      # 電子レセプト(RECEIPTC.UKE)
      # 診療報酬請求書
      class DigitalizedReceipt
        extend Forwardable

        # @param seikyuu_ym [Month] 請求年月
        # @param audit_payer [AuditPayer] 審査支払機関
        # @param hospital [Hospital] 医療機関
        def initialize(seikyuu_ym:, audit_payer:, hospital:)
          @seikyuu_ym  = seikyuu_ym
          @audit_payer = audit_payer
          @hospital    = hospital
          @receipts    = []
        end

        # @param receipt [Receipt]
        # @return [void]
        def add_receipt(receipt)
          @receipts << receipt
        end

        # @!attribute [r] seikyuu_ym
        #   @return [Month] 請求年月
        # @!attribute [r] audit_payer
        #   @return [AuditPayer] 審査支払機関
        # @!attribute [r] hospital
        #   @return [Hospital] 医療機関
        attr_reader :seikyuu_ym, :audit_payer, :hospital

        def_delegators :@receipts, :each, :each_with_index, :map, :to_a, :[]
      end
    end
  end
end
