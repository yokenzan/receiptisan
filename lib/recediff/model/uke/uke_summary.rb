# frozen_string_literal: true

module Recediff
  module Model
    module Uke
      class UkeSummary
        attr_reader :hospital, :receipts

        def initialize(hospital, receipts)
          @hospital = hospital
          @receipts = receipts
        end

        def to_s
          [@hospital, @receipts].join("\n")
        end
      end
    end
  end
end
