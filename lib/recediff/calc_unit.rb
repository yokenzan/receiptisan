# frozen_string_literal: true

module Recediff
  class CalcUnit
    extend Forwardable
    def_delegators :@costs, :map, :length, :empty?

    def initialize(shinku)
      @costs   = []
      @shinku  = shinku
      @point   = nil
      @done_at = []
    end

    def reinitialize
      return self if @costs.empty?

      @point   = @costs.sum { | c | c.point.to_i }
      @done_at = @costs.first.done_at
      self
    end

    def find_by_code(code)
      @records.find { | r | r.code == code }
    end

    def add_cost(cost)
      @costs << cost
    end

    def sort!
      @costs.sort_by! { | c | c.code }
      self
    end

    def uniq_id
      "%02d%02d%0d%05d%02d" % [shinku, done_at.first, @costs.first.code, point, length]
    end

    def show(index, day)
      text = []
      text << "# 診区 %02d - %5d点 - レコード%2d件" % [shinku, point_at(day), length]
      text << map.with_index { | c, index | c.show(index) }

      text.join("\n")
    end

    def done_at?(day)
      done_at.include?(day)
    end

    def point_at(day)
      @costs.sum { | c | c.point_at(day) }
    end

    attr_reader :shinku, :point, :done_at
  end
end
