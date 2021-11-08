# frozen_string_literal: true

module Recediff
  # A class which represents cost records in UKE such as SI, IY, TO.
  class Cost
    # @param [String, Integer] code Rece-den code for the cost.
    # @param [Array<String>] master_record
    # @param [String] category Record cost types such as SI for shinryo-koi.
    # @param [Array<nil, String>] row Record content as an Array.
    def initialize(code, master_record, category, row)
      @code          = code.to_i
      @name          = master_record&.at(1)
      @category      = category
      @row           = row
      @point         = @row.at(COST::POINT) ? @row.at(COST::POINT).to_i : nil
      @done_at       = @row[-31..-1].
        map.with_index { | day, index | !day.nil? ? index + 1 : nil }.
        compact
      @count_at      = @row[-31..-1].map(&:to_i)
      @count         = @count_at.inject(0, &:+)
      @master_record = master_record
      @comments      = []
    rescue => e
      $ERR += 1
    end

    def add_comment(comment)
      @comments << comment
    end

    def show(index, day)
      "--> %s - %2d - %4d点 - %s %s" % [category, index, point_at(day), code, @name]
    end

    def point_at(day)
      @point.to_i * @count_at.at(day - 1)
    end

    def code_table_number
      return nil unless category == 'SI'
      return nil unless @master_record

      number = '%s%03d' % [@master_record.at(5), @master_record.at(6).to_i]
      number += '-%d' % @master_record.at(7).to_i unless @master_record.at(7).to_i == 0
      number += ' %d' % @master_record.at(8).to_i unless @master_record.at(8).to_i == 0

      number
    end

    def code_table_upper_category
      category == 'SI' ? @master_record&.at(3).to_i : nil
    end

    def code_table_lower_category
      category == 'SI' ? @master_record&.at(4).to_i : nil
    end

    attr_reader :code, :name, :category, :point, :done_at, :count, :comments
  end

  class Comment
    extend Forwardable

    def initialize(core, category, row)
      @core            = core
      @category        = category
      @row             = row
      @point           = nil
      @done_at         = []
      @count_at        = []
      @count           = 0
      @additional_text = @row.at(4)
    end

    def show(index, day)
      "--> %s - %2d - %4d点 - %s %s" % [category, index, 0, code, name]
    end

    def point_at(day)
      0
    end

    def name
      text.to_s + additional_text.to_s
    end

    def code_table_number; end

    def code_table_upper_category; end

    def code_table_lower_category; end

    def comments
      []
    end

    attr_reader :category, :point, :done_at, :count
    def_delegators :@core, :code, :text, :additional_text
  end

  class CommentCore
    def initialize(code, text, additional_text)
      @code            = code.to_i
      @text            = text
      @additional_text = additional_text
    end

    def name
      text.to_s + additional_text.to_s
    end

    attr_reader :code, :text, :additional_text
  end
end
