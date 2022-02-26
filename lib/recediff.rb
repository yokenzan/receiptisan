# frozen_string_literal: true

require_relative 'recediff/calc_unit'
require_relative 'recediff/cli'
require_relative 'recediff/cost'
require_relative 'recediff/hospital'
require_relative 'recediff/master'
require_relative 'recediff/parser'
require_relative 'recediff/receipt'
require_relative 'recediff/syobyo'
require_relative 'recediff/version'

module Recediff
  class Error < StandardError; end

  module RE
    RECEIPT_ID   = 1
    TYPES        = 2
    TOKKI_JIKO   = 11
    PATIENT_ID   = 13
    PATIENT_NAME = 36
  end

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

tokki_jikos = {
  '01': '公',
  '02': '長',
  '03': '長処',
  '04': '後保',
  '07': '老併',
  '08': '老健',
  '09': '施',
  '10': '第三',
  '11': '薬治',
  '12': '器治',
  '13': '先進',
  '14': '制超',
  '16': '長２',
  '20': '二割',
  '21': '高半',
  '25': '出産',
  '26': '区ア',
  '27': '区イ',
  '28': '区ウ',
  '29': '区エ',
  '30': '区オ',
  '31': '多ア',
  '32': '多イ',
  '33': '多ウ',
  '34': '多エ',
  '35': '多オ',
  '36': '加治',
  '37': '申出',
  '38': '医併',
  '39': '医療'
}
