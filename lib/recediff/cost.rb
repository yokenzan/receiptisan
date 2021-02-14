# frozen_string_literal: true

module Recediff
  # A class which represents cost records in UKE such as SI, IY, TO.
  class Cost
    # @param [String, Integer] code Rece-den code for the cost.
    # @param [String] name Japanese name for the cost.
    # @param [String] category Record cost types such as SI for shinryo-koi.
    # @param [Array<nil, String>] row Record content as an Array.
    def initialize(code, name, category, row)
      @code     = code.to_i
      @name     = name
      @category = category
      @row      = row
      @point    = @row.at(COST::POINT) ? @row.at(COST::POINT).to_i : nil
      @done_at  = @row[-31..-1].
        map.with_index { | day, index | !day.nil? ? index + 1 : nil }.
        compact
      @count_at = @row[-31..-1].map(&:to_i)
    end

    def show(index)
      "--> %s - %2d - %4d点 - %s %s" % [category, index, point.to_i, code, @name]
    end

    def point_at(day)
      @point.to_i * @count_at.at(day - 1)
    end

    attr_reader :code, :category, :point, :done_at
  end
end
