# frozen_string_literal: true

require 'month'
require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class Master
        class Version
          class << self
            # @param ym [Month]
            # @return [Version, nil]
            def resolve_by_ym(ym)
              # @param v [Version]
              values.find { | v | v.include?(ym) }
            end

            # @return [Array<Version>]
            def values
              constants.map { | name | const_get(name) }
            end
          end

          extend Forwardable

          # @param year [Integer]
          # @param start_ym [Month]
          # @param end_ym [Month]
          def initialize(year, start_ym, end_ym)
            @year = year
            @term = start_ym..end_ym
          end

          # @!attribute [r] year
          #   @return [Integer]
          # @!attribute [r] term
          #   @return [Range<Month>]
          attr_reader :year, :term

          def_delegators :@term, :include?

          V2018_H30 = new(2018, Month.new(2018, 4), Month.new(2019, 3))
          V2019_R01 = new(2019, Month.new(2019, 4), Month.new(2020, 3))
          V2020_R02 = new(2020, Month.new(2020, 4), Month.new(2022, 3))
          V2022_R04 = new(2022, Month.new(2022, 4), Month.new(2024, 3))
        end
      end
    end
  end
end
