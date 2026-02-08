# frozen_string_literal: true

require 'month'

module Receiptisan
  module Util
    module MonthExtension
      refine Month do
        # @param day [Integer] 日番号(1-31)
        # @return [Date]
        def of_date(day)
          Date.new(year, number, day)
        end
      end
    end
  end
end
