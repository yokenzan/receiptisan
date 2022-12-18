# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Util
        class ReceiptEnumeratorGenerator
          class << self
            # @param receipt [Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt]
            # @param shinryou_shikibetsu_codes [Array<Integer>]
            # @param resource_types [Array<Symbol>]
            # @return [Enumnerator]
            def each_cost_for(receipt:, shinryou_shikibetsu_codes: [], resource_types: [])
              Enumerator.new do | y |
                shinryou_shikibetsu_codes.each do | shinryou_shikibetsu_code |
                  (receipt[shinryou_shikibetsu_code] || []).each do | ichiren |
                    ichiren.each do | santei |
                      next unless target_santei_unit?(santei, resource_types)

                      santei.each_cost { | cost | y << cost }
                    end
                  end
                end
              end
            end

            # @param receipt [Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt]
            # @param shinryou_shikibetsu_codes [Array<Integer>]
            # @param resource_types [Array<Symbol>]
            # @return [Enumnerator]
            def each_santei_unit(receipt:, shinryou_shikibetsu_codes: [], resource_types: [])
              Enumerator.new do | y |
                shinryou_shikibetsu_codes.each do | shinryou_shikibetsu_code |
                  (receipt[shinryou_shikibetsu_code] || []).each do | ichiren |
                    ichiren.each do | santei |
                      y << santei if target_santei_unit?(santei, resource_types)
                    end
                  end
                end
              end
            end

            def target_santei_unit?(santei_unit, resource_types)
              not_filtered = resource_types.empty?
              includes     = resource_types.include?(santei_unit.resource_type)

              not_filtered || includes
            end
          end
        end
      end
    end
  end
end
