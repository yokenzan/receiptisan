# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # レセプト種別
          class Type
            # @param tensuu_hyou_type [TensuuHyouType] 点数表種別
            # @param main_hoken_type [MainHokenType] 主保険種別
            # @param hoken_multiple_type [HokenMultipleType] 保険併用種別
            # @param patient_age_type [PatientAgeType] 患者年齢種別
            def initialize(tensuu_hyou_type, main_hoken_type, hoken_multiple_type, patient_age_type)
              @tensuu_hyou_type    = tensuu_hyou_type
              @main_hoken_type     = main_hoken_type
              @hoken_multiple_type = hoken_multiple_type
              @patient_age_type    = patient_age_type
            end

            def nyuuin?
              @patient_age_type.nyuuin?
            end

            # @!attribute [r] tensuu_hyou_type
            #   @return [TensuuHyouType] 点数表種別
            # @!attribute [r] main_hoken_type
            #   @return [MainHokenType] 主保険種別
            # @!attribute [r] hoken_multiple_type
            #   @return [HokenMultipleType] 保険併用種別
            # @!attribute [r] patient_age_type
            #   @return [PatientAgeType] 患者年齢種別
            attr_reader :tensuu_hyou_type, :main_hoken_type, :hoken_multiple_type, :patient_age_type

            # 点数表種別
            class TensuuHyouType
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              # @!attribute [r] code
              #   @return [Integer]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name

              @types = {
                '1': new(code: 1, name: '医科'),
              }
              @types.each(&:freeze).freeze

              class << self
                # @param code [String, Integer]
                # @return [self, nil]
                def find_by_code(code)
                  @types[code.to_s.intern]
                end
              end
            end

            # 主保険種別
            class MainHokenType
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              # @!attribute [r] code
              #   @return [Integer]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name
            end

            # 保険併用種別
            class HokenMultipleType
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              # @!attribute [r] code
              #   @return [Integer]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name

              @types = {
                '1': new(code: 1, name: '単独'),
                '2': new(code: 2, name: '２併'),
                '3': new(code: 3, name: '３併'),
                '4': new(code: 4, name: '４併'),
              }
              @types.each(&:freeze).freeze

              class << self
                # @param code [String, Integer]
                # @return [self, nil]
                def find_by_code(code)
                  @types[code.to_s.intern]
                end
              end
            end

            # 患者年齢種別
            class PatientAgeType
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              def nyuuin?
                code.odd?
              end

              # @!attribute [r] code
              #   @return [Integer]
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
              @types.each(&:freeze).freeze

              class << self
                # @param code [String, Integer]
                # @return [self, nil]
                def find_by_code(code)
                  @types[code.to_s.intern]
                end
              end
            end
          end
        end
      end
    end
  end
end
