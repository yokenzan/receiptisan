# frozen_string_literal: true

require 'date'

module Recediff
  class Patient
    class << self
      RE = Model::Uke::Enum::RE

      # @return [Patient]
      def from_uke(row)
        new(
          id:         row.at(RE::C_カルテ番号等).to_i,
          name:       row.at(RE::C_氏名),
          name_kana:  row.at(RE::C_カタカナ氏名),
          sex:        row.at(RE::C_男女区分).to_i,
          birth_date: row.at(RE::C_生年月日)
        )
      end

      # @return [Patient]
      def create_empty
        new(
          id:         '不明',
          name:       '不明',
          name_kana:  '不明',
          sex:        '不明',
          birth_date: '不明'
        )
      end
    end

    def initialize(id:, name:, name_kana:, sex:, birth_date:)
      @id         = id
      @name       = name
      @sex        = sex
      @birth_date = birth_date
      @birthday   = Date.parse(@birth_date) if aged?
      @name_kana  = name_kana
    end

    def empty?
      [id, name, name_kana, sex, birth_date].all? { | v | v.nil? || v == '不明' }
    end

    def aged?
      return false if @birth_date.nil?
      return false if @birth_date.empty?
      return false if @birth_date !~ /^\d+$/

      true
    end

    # @param [Month] month
    # @return [Integer, nil]
    def age_of(month)
      return nil unless aged?
      return nil unless month

      age_year = month.year - Month(@birthday).year
      age_year -= 1 if month.number < Month(@birthday).number
      age_year
    end

    # @param [Month] month
    # @return [Integer, nil]
    def age_month_of(month)
      return nil unless aged?
      return nil unless month

      age_month = month.number - Month(@birthday).number
      age_month >= 0 ? age_month : 12 + age_month
    end

    # @!attribute [r]
    # @return [String, Integer, nil]
    attr_reader :id
    # @!attribute [r]
    # @return [String]
    attr_reader :name
    # @!attribute [r]
    # @return [Integer?]
    attr_reader :sex
    # @!attribute [r]
    # @return [String?]
    attr_reader :name_kana
    # @!attribute [r]
    # @return [String?]
    attr_reader :birth_date
    # @!attribute [r]
    # @return [Date?]
    attr_reader :birthday
  end
end
