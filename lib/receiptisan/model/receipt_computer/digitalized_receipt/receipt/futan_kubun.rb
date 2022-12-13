# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # 負担区分
          class FutanKubun
            def initialize(code:, mapping:)
              @code    = code
              @mapping = mapping
            end

            # @param hoken_order [HokenOrder]
            def uses?(hoken_order)
              mapping & hoken_order.filter_bits == hoken_order.filter_bits
            end

            # @!attribute [r] code
            #   @return [String]
            # @!attribute [r] mapping
            #   @return [Integer]
            attr_reader :code, :mapping

            @list = {
              # 1者
              '1': new(code: :'1', mapping: 0b10000),
              '5': new(code: :'5', mapping: 0b01000),
              '6': new(code: :'6', mapping: 0b00100),
              B:   new(code: :B,   mapping: 0b00010),
              C:   new(code: :C,   mapping: 0b00001),
              # 2者
              '2': new(code: :'2', mapping: 0b11000),
              '3': new(code: :'3', mapping: 0b10100),
              E:   new(code: :E,   mapping: 0b10010),
              G:   new(code: :G,   mapping: 0b10001),
              '7': new(code: :'7', mapping: 0b01100),
              H:   new(code: :H,   mapping: 0b01010),
              I:   new(code: :I,   mapping: 0b01001),
              J:   new(code: :J,   mapping: 0b00110),
              K:   new(code: :K,   mapping: 0b00101),
              L:   new(code: :L,   mapping: 0b00011),
              # 3者
              '4': new(code: :'4', mapping: 0b11100),
              M:   new(code: :M,   mapping: 0b11010),
              N:   new(code: :N,   mapping: 0b11001),
              O:   new(code: :O,   mapping: 0b10110),
              P:   new(code: :P,   mapping: 0b10101),
              Q:   new(code: :Q,   mapping: 0b10011),
              R:   new(code: :R,   mapping: 0b01110),
              S:   new(code: :S,   mapping: 0b01101),
              T:   new(code: :T,   mapping: 0b01011),
              U:   new(code: :U,   mapping: 0b00111),
              # 4者
              V:   new(code: :V,   mapping: 0b11110),
              W:   new(code: :W,   mapping: 0b11101),
              X:   new(code: :X,   mapping: 0b11011),
              Y:   new(code: :Y,   mapping: 0b10111),
              Z:   new(code: :Z,   mapping: 0b01111),
              # 5者
              '9': new(code: :'9', mapping: 0b11111),
            }
            @list.each(&:freeze).freeze

            class << self
              # 左から医保、第一～第四公費の順
              # @param code [Symbol, String, Integer]
              # @return [self, nil]
              def find_by_code(code)
                @list[code.to_s.intern]
              end
            end

            class HokenOrder
              HOKEN_ORDER_IRYOU_HOKEN = :'0'
              HOKEN_ORDER_KOUHI_1     = :'1'
              HOKEN_ORDER_KOUHI_2     = :'2'
              HOKEN_ORDER_KOUHI_3     = :'3'
              HOKEN_ORDER_KOUHI_4     = :'4'

              def initialize(code:, name:, filter_bits:)
                @code   = code
                @name   = name
                @filter_bits = filter_bits
              end

              attr_reader :code, :name, :filter_bits

              @list = {
                HOKEN_ORDER_IRYOU_HOKEN => new(code: :'0', name: '医療保険', filter_bits: 0b10000),
                HOKEN_ORDER_KOUHI_1 => new(code: :'1', name: '第一公費', filter_bits: 0b01000),
                HOKEN_ORDER_KOUHI_2 => new(code: :'2', name: '第二公費', filter_bits: 0b00100),
                HOKEN_ORDER_KOUHI_3 => new(code: :'3', name: '第三公費', filter_bits: 0b00010),
                HOKEN_ORDER_KOUHI_4 => new(code: :'4', name: '第四公費', filter_bits: 0b00001),
              }

              class << self
                # @param is_kouhi [Boolean]
                # @return [self, nil]
                def kouhi_futan_iryou(index)
                  @list[(index + 1).to_s.intern]
                end

                def iryou_hoken
                  @list[:'0']
                end

                def find_by_code(code)
                  @list[code.to_s.intern]
                end

                def each_hoken_order(&block)
                  return @list.enum_for(:each) unless block_given?

                  @list.each(&block)
                end
              end
            end
          end
        end
      end
    end
  end
end
