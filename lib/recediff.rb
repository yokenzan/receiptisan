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
require_relative 'recediff/output'
require_relative 'recediff/cli'
require_relative 'recediff/escape_sequence_interior_builder'

module Recediff
  class Error < StandardError; end

  module SYOBYO
    CODE        = 1
    START_DATE  = 2
    TENKI       = 3
    SHUSHOKUGO  = 4
    WORPRO_NAME = 5
    IS_MAIN     = 6
  end
end
