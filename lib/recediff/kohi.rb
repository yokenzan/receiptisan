# frozen_string_literal: true

module Recediff
  class Kohi
    # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators
    C_レコード識別情報           = 0
    C_公費負担者番号             = 1
    C_受給者番号                 = 2
    C_任意給付区分               = 3
    C_診療実日数                 = 4
    C_合計点数                   = 5
    C_公費負担金額               = 6
    C_公費給付対象外来一部負担金 = 7
    C_公費給付対象入院一部負担金 = 8
    C_食事療養回数               = 10
    C_食事療養合計金額           = 11
    # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators

    def initialize(row)
      @row = row
    end

    def futansha_bango
      @row.at(C_公費負担者番号)
    end

    def jukyusha_bango
      @row.at(C_受給者番号)
    end

    def point
      @row.at(C_合計点数)&.to_i
    end

    def futankin
      @row.at(C_公費負担金額)&.to_i
    end

    def gairai_futankin
      @row.at(C_公費給付対象外来一部負担金)&.to_i
    end

    def nyuin_futankin
      @row.at(C_公費給付対象入院一部負担金)&.to_i
    end

    # @return [Integer]
    def day_count
      @row.at(C_診療実日数).to_i
    end
  end
end
