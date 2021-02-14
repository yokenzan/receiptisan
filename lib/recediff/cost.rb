# frozen_string_literal: true

module Recediff
  class Cost
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
