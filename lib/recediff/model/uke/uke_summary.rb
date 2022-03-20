# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module Uke
      class UkeSummary
        extend Forwardable
        include Enumerable

        def_delegator :@receipts, :each

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
