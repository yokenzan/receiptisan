# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Util
        class ReceiptEnumeratorGenerator
          class << self
            # @param receipt [Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt]
            # @return [Enumnerator]
            def cost_enum_from(receipt, *shinryou_shikibetsu_codes)
              Enumerator.new do | y |
                receipt.each do | shinryou_shikibetsu_code, section |
                  is_empty = shinryou_shikibetsu_codes.empty?
                  includes = shinryou_shikibetsu_codes.include?(shinryou_shikibetsu_code)
                  next if !is_empty && !includes

                  section.each { | ichiren | ichiren.each { | santei | santei.each_cost { | cost | y << cost } } }
                end
              end
            end
          end
        end
      end
    end
  end
end