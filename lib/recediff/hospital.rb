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
  end
end
