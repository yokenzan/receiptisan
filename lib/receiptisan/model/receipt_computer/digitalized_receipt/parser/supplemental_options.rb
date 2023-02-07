# frozen_string_literal: true

require 'json'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          class SupplementalOptions
            class << self
              def from(options)
                hospitals = options.nil? ? [] : JSON.parse(options).map { | param | HospitalOption.from(param) }
                hospitals << HospitalOption.new(code: nil, location: '', bed_count: 0)

                new(hospitals: hospitals)
              end
            end

            def initialize(hospitals:)
              @hospitals = hospitals
            end

            # @param hospital_code [String]
            # @return [HospitalOption, nil]
            def find_by_code(hospital_code)
              @hospitals.find { | option | option.matches?(hospital_code) }
            end

            HospitalOption = Struct.new(:code, :location, :bed_count, keyword_init: true) do
              class << self
                # @param option [Hash]
                # @return [self]
                def from(option)
                  new(
                    code:      option['code'],
                    location:  option['location'],
                    bed_count: (option['bed-count'] || 0).to_i
                  )
                end
              end

              # @param hospital_code [String, nil]
              def matches?(hospital_code)
                hospital_code.nil? || code.nil? ? true : hospital_code == code
              end
            end
          end
        end
      end
    end
  end
end
