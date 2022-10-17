# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 診療報酬請求明細書(レセプト)
        class Receipt
          # @param id [Integer]
          # @param patient [Patient]
          # @param hospital [Hospital]
          # @param type [Type]
          # @param tokki_jikous [Array<TokkiJikou>]
          def initialize(id:, patient:, hospital:, type:, tokki_jikous:)
            @id           = id
            @patient      = patient
            @hospital     = hospital
            @type         = type
            @tokki_jikous = tokki_jikous
          end

          # @!attribute [r] id
          #   @return [Integer]
          attr_reader :id
          # @!attribute [r] patient
          #   @return [Patient]
          attr_reader :patient
          # @!attribute [r] hospital
          #   @return [Hospital]
          attr_reader :hospital
          # @!attribute [r] type
          #   @return [Type]
          attr_reader :type
          # @!attribute [r] tokki_jikous
          #   @return [Array<TokkiJikou]
          attr_reader :tokki_jikous
        end
      end
    end
  end
end

