# frozen_string_literal: true

require 'date'

module Receiptisan
  module Util
    module MonthExtention
      refine Month do
        # @param [Integer] day
        # @return [Date]
        def of_date(day)
          Date.new(year, number, day)
        end
      end
    end
  end
end
