# frozen_string_literal: true

module Receiptisan
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

            # TODO: 処理を他に移す、適切なかたちにEnum化する
            # @return [Symbol]
            def classification
              # 公費
              return :kouhi if main_hoken_type.kouhi?

              case # rubocop:disable Style/EmptyCaseCondition
              when patient_age_type.mishuugakuji?
                # 未就学児
                :mishuugakuji
              when patient_age_type.kourei_ippan?
                # 高齢受給者一般・低所得
                # 後期高齢者一般・低所得
                main_hoken_type.kouki? ? :kouki_ippan : :kourei_ippan
              when patient_age_type.kourei_geneki?
                # 高齢受給者現役並み
                # 後期高齢者現役並み
                main_hoken_type.kouki? ? :kouki_geneki : :kourei_geneki
              else
                # 一般
                :ippan
              end
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
              TYPE_IKA = :'1'

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
                TYPE_IKA => new(code: TYPE_IKA.to_s.to_i, name: '医科'),
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

              def kouki?
                name == '後期'
              end

              def kouhi?
                name == '公費'
              end

              # @!attribute [r] code
              #   @return [Integer]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name
            end

            # 保険併用種別
            class HokenMultipleType
              TYPE_TANDOKU  = :'1'
              TYPE_2_HEIYOU = :'2'
              TYPE_3_HEIYOU = :'3'
              TYPE_4_HEIYOU = :'4'

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
                TYPE_TANDOKU => new(code: TYPE_TANDOKU.to_s.to_i, name: '単独'),
                TYPE_2_HEIYOU => new(code: TYPE_2_HEIYOU.to_s.to_i, name: '２併'),
                TYPE_3_HEIYOU => new(code: TYPE_3_HEIYOU.to_s.to_i, name: '３併'),
                TYPE_4_HEIYOU => new(code: TYPE_4_HEIYOU.to_s.to_i, name: '４併'),
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

              def ippan?
                name.include?('本') || name.include?('家')
              end

              def mishuugakuji?
                name.include?('六')
              end

              def kourei_ippan?
                name.include?('一')
              end

              def kourei_geneki?
                name.include?('７')
              end

              # @!attribute [r] code
              #   @return [Integer]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name

              @types = {
                '1': new(code: 1, name: '本入'),
                '2': new(code: 2, name: '本外'),
                '3': new(code: 3, name: '六入'),
                '4': new(code: 4, name: '六外'),
                '5': new(code: 5, name: '家入'),
                '6': new(code: 6, name: '家外'),
                '7': new(code: 7, name: '高入一'),
                '8': new(code: 8, name: '高外一'),
                '9': new(code: 9, name: '高入７'),
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
