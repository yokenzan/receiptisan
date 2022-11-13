# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class SIProcessor
              SI                 = DigitalizedReceipt::Record::SI
              ShinryouKoui       = Receipt::Tekiyou::Cost::ShinryouKoui
              MasterShinryouKoui = Master::Treatment::ShinryouKoui

              # @param handler [MasterHandler]
              def initialize(handler)
                @handler = handler
              end

              # @param values [Array<String, nil>] SI行
              # @return [Receipt::Tekiyou::Cost::ShinryouKoui]
              def process(values)
                raise StandardError, 'line isnt SI record' unless values.first == 'SI'

                ShinryouKoui.new(
                  shiyouryou:           values[SI::C_数量データ]&.to_i,
                  master_shinryou_koui: handler.find_by_code(
                    MasterShinryouKoui::Code.of(values[SI::C_レセ電コード])
                  )
                )
              end

              private

              attr_reader :handler
            end
          end
        end
      end
    end
  end
end
