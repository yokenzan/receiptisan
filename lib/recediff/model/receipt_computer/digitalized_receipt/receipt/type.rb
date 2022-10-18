# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # レセプト種別
          class Type
            def initialize(tensuu_hyou_type, main_hoken_type, hoken_multiple_type, patient_age_type)
              @tensuu_hyou_type    = tensuu_hyou_type
              @main_hoken_type     = main_hoken_type
              @hoken_multiple_type = hoken_multiple_type
              @patient_age_type    = patient_age_type
            end

            attr_reader :tensuu_hyou_type, :main_hoken_type, :hoken_multiple_type, :patient_age_type

            class TensuuHyouType
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              # @!attribute [r] code
              #   @return [String]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name

              @types = {
                '1': new(code: 1, name: '医科'),
              }

              class << self
                # @param code [String, Integer]
                # @return [self, nil]
                def find_by_code(code)
                  @types[code.to_s.intern]
                end
              end
            end

            class MainHokenType
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              # @!attribute [r] code
              #   @return [String]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name

              @types = {
                '1': new(code: 1, name: '国保・社保'),
                '2': new(code: 2, name: '公費'),
                '3': new(code: 3, name: '後期'),
                '4': new(code: 4, name: '退職'),
              }

              class << self
                # @param code [String, Integer]
                # @return [self, nil]
                def find_by_code(code)
                  @types[code.to_s.intern]
                end
              end
            end

            class HokenMultipleType
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              # @!attribute [r] code
              #   @return [String]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name

              @types = {
                '1': new(code: 1, name: '単独'),
                '2': new(code: 2, name: '２併'),
                '3': new(code: 3, name: '３併'),
                '4': new(code: 4, name: '４併'),
              }

              class << self
                # @param code [String, Integer]
                # @return [self, nil]
                def find_by_code(code)
                  @types[code.to_s.intern]
                end
              end
            end

            class PatientAgeType
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              # @!attribute [r] code
              #   @return [String]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name

              @types = {
                '1': new(code: 2, name: '本入'),
                '2': new(code: 2, name: '本外'),
                '3': new(code: 4, name: '六入'),
                '4': new(code: 4, name: '六外'),
                '5': new(code: 6, name: '家入'),
                '6': new(code: 6, name: '家外'),
                '7': new(code: 8, name: '高入一'),
                '8': new(code: 8, name: '高外一'),
                '9': new(code: 0, name: '高入７'),
                '0': new(code: 0, name: '高外７'),
              }

              class << self
                # @param code [String, Integer]
                # @return [self, nil]
                def find_by_code(code)
                  @types[code.to_s.intern]
                end
              end
            end

            class << self
              @@types = [
                TensuuHyouType,
                MainHokenType,
                HokenMultipleType,
                PatientAgeType,
              ]

              # @param code_of_types [String]
              # @return [self, nil]
              def of(code_of_types)
                types = code_of_types
                  .to_s
                  .chars
                  .map.with_index { | code, index | @@types[index].find_by_code(code) }
                  .compact

                new(*types)
              end
            end
          end
        end
      end
    end
  end
end
