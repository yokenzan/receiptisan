# frozen_string_literal: true

module Recediff
  class Kohi
    class << self
      KO = Model::Uke::Enum::KO

      def from_uke(row)
        new(
          futansha_bango:  row.at(KO::C_公費負担者番号)&.strip,
          jukyusha_bango:  row.at(KO::C_公費受給者番号)&.strip,
          point:           row.at(KO::C_合計点数)&.to_i,
          futankin:        row.at(KO::C_負担金額_公費)&.to_i,
          gairai_futankin: row.at(KO::C_公費給付対象外来一部負担金)&.to_i,
          nyuin_futankin:  row.at(KO::C_公費給付対象入院一部負担金)&.to_i,
          day_count:       row.at(KO::C_診療実日数).to_i
        )
      end
    end

    def initialize(futansha_bango:, jukyusha_bango:, point:, futankin:, gairai_futankin:, nyuin_futankin:, day_count:) # rubocop:disable Metrics/ParameterLists
      @futansha_bango  = futansha_bango
      @jukyusha_bango  = jukyusha_bango
      @point           = point
      @futankin        = futankin
      @gairai_futankin = gairai_futankin
      @nyuin_futankin  = nyuin_futankin
      @day_count       = day_count
    end

    # !@attribute [r]
    # @return [Integer?]
    attr_reader :futansha_bango
    # !@attribute [r]
    # @return [Integer?]
    attr_reader :jukyusha_bango
    # !@attribute [r]
    # @return [Integer]
    attr_reader :point
    # !@attribute [r]
    # @return [Integer?]
    attr_reader :futankin
    # !@attribute [r]
    # @return [Integer?]
    attr_reader :gairai_futankin
    # !@attribute [r]
    # @return [Integer?]
    attr_reader :nyuin_futankin
    # !@attribute [r]
    # @return [Integer]
    attr_reader :day_count
  end
end
