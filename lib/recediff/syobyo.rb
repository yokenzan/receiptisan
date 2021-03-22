# frozen_string_literal: true

module Recediff
  class Syobyo
    @@tenkis = {
      :'1' => '継続',
      :'2' => '治癒',
      :'3' => '死亡',
      :'4' => '中止',
    }

    # @param [Integer] tenki_code
    def initialize(disease, start_date, tenki_code, is_main)
      @disease     = disease
      @start_date  = start_date
      @tenki       = @@tenkis[tenki_code.to_s.intern]
      @is_main     = !!is_main
      @shushokugos = []
    end

    def add_shushokugo(shushokugo)
      @shushokugos << shushokugo
    end

    def to_list(patient_id)
      is_main = @is_main ? '（主）' : ''
      disease = @shushokugos.select(&:prefix?).
        push(@disease).
        concat(@shushokugos.reject(&:prefix?)).
        map(&:to_s).
        join('')
      start_date = @start_date
      tenki      = @tenki

      "%05d\t〇%s\n%05d\t\t%s\n%05d\t\t%s" % [
        patient_id, is_main + disease,
        patient_id, start_date,
        patient_id, tenki
      ]
    end

    def code
      @disease.code.to_i
    end

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
      def initialize(code, name, is_prefix)
        @code      = code
        @name      = name
        @is_prefix = is_prefix

      end
      def to_s
        @name
      end

      def prefix?
        !!@is_prefix
      end
    end
  end
end
