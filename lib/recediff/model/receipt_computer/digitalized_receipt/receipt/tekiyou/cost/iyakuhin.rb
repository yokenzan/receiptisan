# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Cost
              class Iyakuhin
                extend Forwardable

                def initialize(master_iyakuhin:, shiyouryou:)
                  @master_iyakuhin = master_iyakuhin
                  @shiyouryou      = shiyouryou
                end

                def to_s
                  master_item.name
                end

                attr_reader :master_iyakuhin, :shiyouryou
                alias master_item master_iyakuhin

                def_delegators :master_item, :code, :name
              end
            end
          end
        end
      end
    end
  end
end
