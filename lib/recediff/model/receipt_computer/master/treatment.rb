# frozen_string_literal: true

require_relative 'treatment/iyakuhin'
require_relative 'treatment/shinryou_koui'
require_relative 'treatment/tokutei_kizai'
require_relative 'treatment/comment'

module Recediff
  module Model
    module ReceiptComputer
      class Master
        module Treatment
          class PriceType
            # @param code [String]]
            # @param name [String]]
            # @param calculator [Proc, nil]
            def initialize(code)
              # def initialize(code:, name:, calculator:)
              @code       = code
              # @name       = name
              # @calculator = calculator
            end

            # @param point [Numeric]
            # @return [Numeric, nil]
            # def calculate(point)
            #   @calculator ? @calculator.call(point) : nil
            # end

            # @!attribute [r] code
            #   @return [String]
            # @!attribute [r] name
            #   @return [String]
            attr_reader :code, :name
          end
        end
      end
    end
  end
end
