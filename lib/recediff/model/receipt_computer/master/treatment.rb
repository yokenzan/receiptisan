# frozen_string_literal: true

require_relative 'treatment/iyakuhin'
require_relative 'treatment/shinryou_koui'
require_relative 'treatment/tokutei_kizai'
require_relative 'treatment/comment'

module Recediff
  module Model
    module ReceiptComputer
      class Master
        module Treatment
          # 点数・金額種別
          class PriceType
            # @param code [String]]
            def initialize(code)
              @code = code
            end

            # @!attribute [r] code
            #   @return [String]
            attr_reader :code
          end
        end
      end
    end
  end
end
