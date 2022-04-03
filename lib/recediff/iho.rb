# frozen_string_literal: true

module Recediff
  class Iho
    class << self
      HO = Model::Uke::Enum::HO

      def from_uke(row)
        new(
          hokenja_bango: row.at(HO::C_保険者番号)&.strip,
          kigo:          row.at(HO::C_被保険者証等の記号)&.strip,
          bango:         row.at(HO::C_被保険者証等の番号)&.strip,
          point:         row.at(HO::C_合計点数)&.to_i,
          futankin:      row.at(HO::C_負担金額_医療保険)&.to_i,
          day_count:     row.at(HO::C_診療実日数).to_i
        )
      end
    end

    def initialize(hokenja_bango:, kigo:, bango:, point:, futankin:, day_count:)
      @hokenja_bango = hokenja_bango
      @kigo          = kigo
      @bango         = bango
      @point         = point
      @futankin      = futankin
      @day_count     = day_count
    end

    # @!attribute [r]
    # @return [String?]
    attr_reader :hokenja_bango

    # @!attribute [r]
    # @return [String?]
    attr_reader :kigo

    # @!attribute [r]
    # @return [String?]
    attr_reader :bango

    # @!attribute [r]
    # @return [Integer?]
    attr_reader :point

    # @!attribute [r]
    # @return [Integer?]
    attr_reader :futankin

    # @!attribute [r]
    # @return [Integer]
    attr_reader :day_count
  end
end
