# frozen_string_literal: true

module Recediff
  module Model
    module Uke
      class HospitalSummary
        attr_reader :code, :prefecture_code, :name, :seikyu_ym, :shaho_or_kokuho, :source

        def initialize(code, prefecture_code, name, seikyu_ym, shaho_or_kokuho, source)
          @code            = code
          @prefecture_code = prefecture_code
          @name            = name
          @seikyu_ym       = seikyu_ym
          @shaho_or_kokuho = shaho_or_kokuho
          @source          = source
        end

        def to_s
          [@code, @name, @seikyu_ym].join("\t")
        end
      end
    end
  end
end
