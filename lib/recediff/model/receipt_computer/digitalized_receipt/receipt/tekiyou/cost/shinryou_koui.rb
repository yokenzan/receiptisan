# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Cost
              class ShinryouKoui
                extend Forwardable

                def initialize(master_shinryou_koui:, shiyouryou:)
                  @master_shinryou_koui = master_shinryou_koui
                  @shiyouryou           = shiyouryou
                end

                def to_s
                  name
                end

                attr_reader :master_shinryou_koui, :shiyouryou
                alias_method :master_item, :master_shinryou_koui

                def_delegators :master_item, :code, :name, :unit
              end
            end
          end
        end
      end
    end
  end
end
