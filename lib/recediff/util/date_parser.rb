# frozen_string_literal: true

require 'date'
require 'month'

module Recediff
  module Util
    class DateParser
      class Gengou
        def initialize(code, name, short_name, base_year)
          @code       = code
          @name       = name
          @short_name = short_name
          @base_year  = base_year
        end

        # @!attribute [r] code
        #   @return [Symbol]
        # @!attribute [r] name
        #   @return [String]
        # @!attribute [r] short_name
        #   @return [String]
        # @!attribute [r] base_year
        #   @return [Integer]
        attr_reader :code, :name, :short_name, :base_year
      end

      # @type [Hash<Symbol, Gengou>]
      @gengous = {
        '1': Gengou.new(1, '明治', '明', 1967),
        '2': Gengou.new(2, '大正', '大', 1911),
        '3': Gengou.new(3, '昭和', '昭', 1925),
        '4': Gengou.new(4, '平成', '平', 1988),
        '5': Gengou.new(5, '令和', '令', 2018),
      }

      class << self
        # @param text [String]
        # @return [Date]
        # @raise ArgumentError
        def parse_date(text)
          case text.length
          when 7
            parse_wareki_date(text)
          when 8
            parse_seireki_date(text)
          else
            throw ArgumentError, 'cant parse as date: ' << text.to_s
          end
        end

        # @param text [String]
        # @return [Date]
        # @raise ArgumentError
        def parse_year_month(text)
          case text.length
          when 5
            parse_wareki_month(text)
          when 6
            parse_seireki_month(text)
          else
            throw ArgumentError, 'cant parse as date: ' << text.to_s
          end
        end

        private

        # @param text [String]
        # @return [Date]
        def parse_wareki_date(text)
          gengou = @gengous[text[0].to_i]
          year   = text[1, 2].to_i
          month  = text[3, 2].to_i
          day    = text[5, 2].to_i

          Date.new(gengou.base_year + year, month, day)
        end

        # @param text [String]
        # @return [Date]
        def parse_seireki_date(text)
          Date.parse(text)
        end

        # @param text [String]
        # @return [Month]
        def parse_wareki_month(text)
          gengou = @gengous[text[0].to_i]
          year   = text[1, 2].to_i
          month  = text[3, 2].to_i

          Month.new(gengou.base_year + year, month)
        end

        # @param text [String]
        # @return [Month]
        def parse_seireki_month(text)
          Month.new(text[0, 4].to_i, text[-2, 2].to_i)
        end
      end
    end
  end
end
