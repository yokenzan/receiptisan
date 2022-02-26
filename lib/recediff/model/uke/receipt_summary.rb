# frozen_string_literal: true

module Recediff
  module Model
    module Uke
      class ReceiptSourceSummary
        attr_reader :sequence, :receipt_type, :year_month, :patient_name, :patient_id, :hospital

        def initialize(
          sequence,
          receipt_type,
          year_month,
          patient_name,
          patient_id,
          hospital
        )
          @sequence     = sequence
          @receipt_type = receipt_type
          @year_month   = year_month
          @patient_name = patient_name
          @patient_id   = patient_id
          @hospital     = hospital
          @source       = []
        end

        def add(sourceRow)
          @source << sourceRow
        end

        def to_s
          [
            @sequence,
            @receipt_type,
            @year_month,
            @patient_id,
            @patient_name,
          ].join("\t")
        end
      end
    end
  end
end
