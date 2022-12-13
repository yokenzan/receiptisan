# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Abbrev
        class Master
          # @param version [Receiptisan::Model::ReceiptComputer::Master::Version]
          # @param addrevs [Hash<Symbol, Array<Abbrev>>]
          def initialize(version:, abbrevs:)
            @version = version
            @abbrevs = abbrevs
            @abbrevs.default = []
          end

          # @param code [Master::Treatment::ShinryouKoui::Code]
          # @return [Array<Abbrev>]
          def find_by_code(code)
            @abbrevs[code.value]
          end

          # @!attribute [r] version
          #   @return [Receiptisan::Model::ReceiptComputer::Master::Version]
          attr_reader :version
        end
      end
    end
  end
end
