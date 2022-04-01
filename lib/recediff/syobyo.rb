# frozen_string_literal: true

require 'date'

module Recediff
  class Syobyo
    class << self
      attr_reader :tenkis
    end

    @tenkis = {
      '1': '継続',
      '2': '治癒',
      '3': '死亡',
      '4': '中止',
    }

    # @param [Integer] tenki_code
    def initialize(disease, start_date, tenki_code, is_main)
      @disease     = disease
      @start_date  = Date.parse(start_date)
      @tenki       = self.class.tenkis[tenki_code.to_s.intern]
      @tenki_code  = tenki_code.to_i
      @is_main     = !!is_main
      @shushokugos = []
    end

    def main?
      @is_main
    end

    def worpro?
      code == 999
    end

    def add_shushokugo(shushokugo)
      @shushokugos << shushokugo
    end

    def main_state_text
      @is_main ? '（主）' : ''
    end

    def name
      @shushokugos.select(&:prefix?)
        .push(@disease)
        .concat(@shushokugos.reject(&:prefix?))
        .map(&:to_s)
        .join('')
    end

    def to_list(patient_id)
      is_main = main_state_text
      disease = @shushokugos.select(&:prefix?)
        .push(@disease)
        .concat(@shushokugos.reject(&:prefix?))
        .map(&:to_s)
        .join('')
      start_date = @start_date
      tenki      = @tenki

      "%05d\t〇%s\n%05d\t\t%s\n%05d\t\t%s" % [
        patient_id, is_main + disease,
        patient_id, start_date,
        patient_id, tenki,
      ]
    end

    def code
      @disease.code.to_i
    end

    attr_reader :tenki, :start_date, :tenki_code

    class Disease
      def initialize(code, name)
        @code = code
        @name = name
      end

      def to_s
        @name
      end

      attr_reader :code
    end

    class Shushokugo
      attr_reader :name, :code

      def initialize(code, name, is_prefix)
        @code      = code
        @name      = name
        @is_prefix = is_prefix
      end

      def to_s
        @name
      end

      def prefix?
        !suffix?
      end

      def suffix?
        !@is_prefix
      end
    end
  end
end
