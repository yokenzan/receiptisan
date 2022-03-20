# frozen_string_literal: true

module Recediff
  class Hospital
    IR = Model::Uke::Enum::IR

    def initialize(row)
      @row = row
    end

    # @return [String]
    def code
      @row[IR::C_医療機関コード]
    end

    # @return [String]
    def prefecture_code
      @row[IR::C_都道府県]
    end

    # @return [String]
    def name
      @row[IR::C_医療機関名称]
    end

    def seikyu_ym
      @row[IR::C_請求年月]
    end

    # @return [String]
    def shaho_or_kokuho
      @row[IR::C_審査支払機関].to_i == 1 ? '社保' : '国保'
    end

    def empty?
      [seikyu_ym, name, prefecture_code, code].compact.all?(&:empty?)
    end
  end
end
