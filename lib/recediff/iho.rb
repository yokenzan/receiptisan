# frozen_string_literal: true

module Recediff
  class Iho
    # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators
    C_レコード識別情報 = 0
    C_保険者番号       = 1
    C_記号             = 2
    C_番号             = 3
    C_診療実日数       = 4
    C_合計点数         = 5
    C_食事療養回数     = 7
    C_食事療養合計金額 = 8
    C_負担金額医療保険 = 11
    # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators

    def initialize(row)
      @row = row
    end

    # @return [String]
    def hokenja_bango
      @row.at(C_保険者番号).strip
    end

    # @return [String?]
    def kigo
      @row.at(C_記号)
    end

    # @return [String?]
    def bango
      @row.at(C_番号)
    end

    # @return [Integer?]
    def point
      @row.at(C_合計点数)&.to_i
    end

    # @return [Integer?]
    def futankin
      @row.at(C_負担金額医療保険)&.to_i
    end

    # @return [Integer]
    def day_count
      @row.at(C_診療実日数).to_i
    end
  end
end
