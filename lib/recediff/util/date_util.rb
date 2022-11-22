# frozen_string_literal: true

require 'date'
require 'month'

module Recediff
  module Util
    class DateUtil
      class Gengou
        def initialize(code, name, short_name, alphabet, base_year)
          @code       = code
          @name       = name
          @short_name = short_name
          @alphabet   = alphabet
          @base_year  = base_year
        end

        # @!attribute [r] code
        #   @return [Symbol]
        # @!attribute [r] name
        #   @return [String]
        # @!attribute [r] short_name
        #   @return [String]
        # @!attribute [r] alphabet
        #   @return [String]
        # @!attribute [r] base_year
        #   @return [Integer]
        attr_reader :code, :name, :short_name, :alphabet, :base_year

        # @type [Hash<Symbol, Gengou>]
        @gengous = {
          '1': Gengou.new(1, '明治', '明', 'M', 1967),
          '2': Gengou.new(2, '大正', '大', 'T', 1911),
          '3': Gengou.new(3, '昭和', '昭', 'S', 1925),
          '4': Gengou.new(4, '平成', '平', 'H', 1988),
          '5': Gengou.new(5, '令和', '令', 'R', 2018),
        }

        class << self
          # @return [Gengou, nil]
          def find_by_alphabet(alphabet)
            @gengous.values.find { | gengou | gengou.alphabet == alphabet }
          end

          # @return [Gengou, nil]
          def find_by_code(code)
            @gengous[code.to_s.intern]
          end
        end
      end

      class << self
        # @param text [String]
        # @return [Date]
        # @raise ArgumentError
        def parse_date(date_text)
          text = date_text.tr('０-９', '0-9')
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
        def parse_year_month(year_month_text)
          text = year_month_text.tr('０-９', '0-9')
          case text.length
          when 5
            parse_wareki_month(text)
          when 6
            parse_seireki_month(text)
          else
            throw ArgumentError, 'cant parse as date: ' << text.to_s
          end
        end

        # @param date [Date]
        def to_wareki(date, zenkaku: false)
          jisx0301 = date.jisx0301
          gengou   = Gengou.find_by_alphabet(jisx0301[0])
          text     = '%s%s年%s月%s日' % [
            gengou.name,
            jisx0301[1, 2],
            jisx0301[4, 2],
            jisx0301[7, 2],
          ]

          text.gsub!(/0([0-9])/, '　\1')
          zenkaku ? text.tr('0-9', '０-９') : text
        end

        private

        # @param text [String]
        # @return [Date]
        def parse_wareki_date(text)
          gengou = Gengou.find_by_code(text[0])
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
          gengou = Gengou.find_by_code(text[0])
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
