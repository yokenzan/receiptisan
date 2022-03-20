# frozen_string_literal: true

require 'date'

module Recediff
  class Patient
    def initialize(id, name, sex, birth_date, name_kana)
      @id         = id
      @name       = name
      @sex        = sex
      @birth_date = birth_date
      @birthday   = Date.parse(@birth_date) if aged?
      @name_kana  = name_kana
      # @name       = name ?
      #   sprintf('患者　%s', @id.to_s.tr('0-9', '０-９')) :
      #   name
    end

    def empty?
      [@id, @name, @name_kana, @sex, @birth_date].all? { | v | v == '不明' }
    end

    def aged?
      return false if @birth_date.nil?
      return false if @birth_date.empty?
      return false if @birth_date !~ /^\d+$/

      true
    end

    def age_of(month)
      return nil unless aged?
      return nil unless month

      age_year = month.year - Month(@birthday).year
      age_year -= 1 if month.number < Month(@birthday).number
      age_year
    end

    def age_month_of(month)
      return nil unless aged?
      return nil unless month

      age_month = month.number - Month(@birthday).number
      age_month >= 0 ? age_month : 12 + age_month
    end

    attr_reader :id, :name, :sex, :birth_date, :name_kana, :birthday
  end
end
