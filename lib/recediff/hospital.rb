# frozen_string_literal: true

require 'month'

module Recediff
  class Hospital
    class << self
      IR = Model::Uke::Enum::IR

      # @param [Array<String, nil>] row
      # @return [Hospital]
      # @raise StandardError
      def from_uke(row)
        raise StandardError unless row.at(IR::C_レコード識別情報) == IR::RECORD.to_s

        new(
          code:            row[IR::C_医療機関コード],
          prefecture_code: row[IR::C_都道府県],
          name:            row[IR::C_医療機関名称],
          seikyu_ym:       row[IR::C_請求年月],
          shaho_or_kokuho: row[IR::C_審査支払機関].to_i == 1 ? '社保' : '国保',
          tel_number:      row[IR::C_電話番号]
        )
      end

      # @return [Hospital]
      def create_empty
        new(
          code:            nil,
          prefecture_code: nil,
          name:            '',
          seikyu_ym:       nil,
          shaho_or_kokuho: nil,
          tel_number:      nil
        )
      end
    end

    # @param [String?] code
    # @param [String?] prefecture_code
    # @param [String] name
    # @param [Month?] seikyu_ym
    # @param [String?] shaho_or_kokuho
    def initialize(code:, prefecture_code:, name:, seikyu_ym:, shaho_or_kokuho:, tel_number:)
      @code            = code
      @prefecture_code = prefecture_code
      @name            = name
      @seikyu_ym       = seikyu_ym
      @shaho_or_kokuho = shaho_or_kokuho
      @tel_number      = tel_number
    end

    def empty?
      [seikyu_ym, name, prefecture_code, code].compact.all?(&:empty?)
    end

    # @!attribute [r]
    # @return [String?]
    attr_reader :code
    # @!attribute [r]
    # @return [String?]
    attr_reader :prefecture_code
    # @!attribute [r]
    # @return [String]
    attr_reader :name
    # @!attribute [r]
    # @return [Month?]
    attr_reader :seikyu_ym
    # @!attribute [r]
    # @return [String?]
    attr_reader :shaho_or_kokuho
    attr_reader :tel_number
  end
end
