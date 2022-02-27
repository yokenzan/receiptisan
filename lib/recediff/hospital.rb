# frozen_string_literal: true

module Recediff
  class Hospital
    def initialize(row)
      @row = row
    end

    def code
      @row[4]
    end

    def prefecture_code
      @row[2]
    end

    def name
      @row[6]
    end

    def seikyu_ym
      @row[7]
    end

    def shaho_or_kokuho
      @row[1].to_i == 1 ? '社保' : '国保'
    end
  end
end
