# frozen_string_literal: true

module Recediff
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

            # @!attribute [r] code
            #   @return [String]
            # @!attribute [r] mapping
            #   @return [Integer]
            attr_reader :code, :mapping

            class << self
              # 左から医保、第一～第四公費の順
              @list = {
                # 1者
                '1': new(:'1', 0b10000),
                '5': new(:'5', 0b01000),
                '6': new(:'6', 0b00100),
                B:   new(:B,   0b00010),
                C:   new(:C,   0b00001),
                # 2者
                '2': new(:'2', 0b11000),
                '3': new(:'3', 0b10100),
                E:   new(:E,   0b10010),
                G:   new(:G,   0b10001),
                '7': new(:'7', 0b01100),
                H:   new(:H,   0b01010),
                I:   new(:I,   0b01001),
                J:   new(:J,   0b00110),
                K:   new(:K,   0b00101),
                L:   new(:L,   0b00011),
                # 3者
                '4': new(:'4', 0b11100),
                M:   new(:M,   0b11010),
                N:   new(:N,   0b11001),
                O:   new(:O,   0b10110),
                P:   new(:P,   0b10101),
                Q:   new(:Q,   0b10011),
                R:   new(:R,   0b01110),
                S:   new(:S,   0b01101),
                T:   new(:T,   0b01011),
                U:   new(:U,   0b00111),
                # 4者
                V:   new(:V,   0b11110),
                W:   new(:W,   0b11101),
                X:   new(:X,   0b11011),
                Y:   new(:Y,   0b10111),
                Z:   new(:Z,   0b01111),
                '9': new(:'9', 0b11111),
              }
              @list.each(&:freeze).freeze

              # @param code [Symbol, String, Integer]
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
