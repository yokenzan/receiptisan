# frozen_string_literal: true

require 'forwardable'

module Recediff
  # 算定単位
  class CalcUnit
    extend Forwardable
    include Enumerable
    def_delegators :@costs, :each, :map, :length, :empty?, :first

    # @param [Integer] shinku 診療識別・診療区分
    def initialize(shinku)
      # @type [Array<Cost>]
      @costs   = []
      @shinku  = shinku
      @point   = nil
      # @type [Array<Integer>]
      @done_at = []
    end

    # @return self
    def reinitialize
      return self if @costs.empty?

      @point    = @costs.sum { | c | c.point.to_i }
      @cost     = @costs.reject { | c | c.is_a?(Comment) }.first
      @done_at  = @cost.done_at
      self
    end

    def comment_only?
      @costs.all? { | c | c.is_a?(Comment) }
    end

    # @param [Cost] cost
    def add_cost(cost)
      @costs << cost
    end

    # @return self
    def sort!
      @costs.sort_by!(&:code)
      self
    end

    # @return [String]
    def uniq_id
      '%02d%02d%0d%05d%02d' % [shinku, done_at.first, first.code, point, length]
    end

    # @param [Integer] day
    # @return [String]
    def show(day)
      text = []
      text << '# 診区 %02d - %5d点 - レコード%2d件' % [shinku, point_at(day), length]
      text << map.with_index { | c, index | c.show(index, day) }

      text.join("\n")
    end

    # 第 +day+ 日目に実施されたか？
    # @param [Integer] day
    # @return [Boolean]
    def done_at?(day)
      done_at.include?(day)
    end

    # 第 +day+ 日目の算定点数
    # @param [Integer] day
    # @return [Integer]
    def point_at(day)
      @costs.sum { | c | c.point_at(day) }
    end

    def count
      first.count
    end

    def count_at(day)
      @cost.count_at(day)
    end

    attr_reader :shinku, :point, :done_at
  end
end
