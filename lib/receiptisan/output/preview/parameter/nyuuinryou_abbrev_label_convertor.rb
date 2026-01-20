# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        class NyuuinryouAbbrevLabelConvertor
          include Receiptisan::Output::Preview::Parameter::Common

          SHINRYOU_SHIKIBETSUS = %w[90 92].freeze
          DigitalizedReceipt   = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt
          ShinryouKoui         = Model::ReceiptComputer::Master::Treatment::ShinryouKoui

          # @param handler [Receiptisan::Model::ReceiptComputer::Abbrev::Handler]
          def initialize(handler)
            @abbrev_handler = handler
          end

          # @param receipt [DigitalizedReceipt::Receipt]
          def convert(receipt)
            return [] unless receipt.nyuuin?

            abbrev_handler.prepare(receipt.shinryou_ym)
            abbrevs = Set.new

            receipt2shinryou_koui_codes(receipt).each { | code | abbrevs.merge(abbrev_handler.find_by_code(code)) }

            abbrevs.sort_by(&:code).map(&:label)
          end

          private

          def receipt2shinryou_koui_codes(receipt)
            SHINRYOU_SHIKIBETSUS.map do | shinryou_shikibetsu_code |
              (receipt[shinryou_shikibetsu_code] || []).map do | ichiren_unit |
                ichiren_unit.each.map do | santei_unit |
                  santei_unit.each_cost
                    .map { | cost | cost.resource.code }
                    .select { | code | code.instance_of?(ShinryouKoui::Code) }
                end
              end
            end.flatten.compact
          end

          # @!attribute [r] abbrev_handler
          #   @return [Receiptisan::Model::ReceiptComputer::Abbrev::Handler]
          attr_reader :abbrev_handler
        end
      end
    end
  end
end
