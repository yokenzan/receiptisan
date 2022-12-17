# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # 低所得区分(手引きでは『一部負担金・食事療養費・生活療養費標準負担額区分コード』)
          #
          # 手引き別表8
          class TeishotokuType
            TYPE_TEISHOTOKU_2         = :'1'
            TYPE_TEISHOTOKU_2_CHOUKI  = :'2'
            TYPE_TEISHOTOKU_1         = :'3'
            TYPE_TEISHOTOKU_1_ROUFUKU = :'4'

            def initialize(code:, name:, short_name:)
              @code       = code
              @name       = name
              @short_name = short_name
            end

            # @!attribute [r] code
            #   @return [Symbol]
            # @!attribute [r] name
            #   @return [String]
            # @!attribute [r] short_name
            #   @return [String]
            attr_reader :code, :name, :short_name

            @list = {
              TYPE_TEISHOTOKU_2 => new(
                code:       TYPE_TEISHOTOKU_2,
                name:       '低所得Ⅱ',
                short_name: 'Ⅱ'
              ),
              TYPE_TEISHOTOKU_2_CHOUKI => new(
                code:       TYPE_TEISHOTOKU_2_CHOUKI,
                name:       '低所得Ⅱ',
                short_name: 'Ⅱ 3月超'
              ),
              TYPE_TEISHOTOKU_1 => new(
                code:       TYPE_TEISHOTOKU_1,
                name:       '低所得Ⅰ',
                short_name: 'Ⅰ'
              ),
              TYPE_TEISHOTOKU_1_ROUFUKU => new(
                code:       TYPE_TEISHOTOKU_1_ROUFUKU,
                name:       '低所得Ⅰ',
                short_name: 'Ⅰ'
              ),
            }
            @list.each(&:freeze).freeze

            class << self
              # @param code [String, Integer, Symbol]
              # @return [self, nil]
              def find_by_code(code)
                @list[code.to_s.intern]
              end
            end
          end
        end
      end
    end
  end
end
