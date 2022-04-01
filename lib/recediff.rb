# frozen_string_literal: true

require_relative 'recediff/version'
require_relative 'recediff/model'
require_relative 'recediff/master'
require_relative 'recediff/buffer'
require_relative 'recediff/patient'
require_relative 'recediff/calc_unit'
require_relative 'recediff/cost'
require_relative 'recediff/syobyo'
require_relative 'recediff/hospital'
require_relative 'recediff/iho'
require_relative 'recediff/kohi'
require_relative 'recediff/receipt'
require_relative 'recediff/parser'
require_relative 'recediff/summary_parser'
require_relative 'recediff/previewer'
require_relative 'recediff/cli'

module Recediff
  class Error < StandardError; end

  module COST
    CATEGORY                  = 0
    SHINKU                    = 1
    CODE                      = 3
    POINT                     = 5
    COMMENT_CODE_1            = 7
    COMMENT_ADDITIONAL_TEXT_1 = 8
    COMMENT_CODE_2            = 9
    COMMENT_ADDITIONAL_TEXT_2 = 10
    COMMENT_CODE_3            = 11
    COMMENT_ADDITIONAL_TEXT_3 = 12
  end

  module HOKEN
    HOKENJA_NUMBER = 1
    TOTAL_POINT    = 5
  end

  module SYOBYO
    CODE        = 1
    START_DATE  = 2
    TENKI       = 3
    SHUSHOKUGO  = 4
    WORPRO_NAME = 5
    IS_MAIN     = 6
  end
end
