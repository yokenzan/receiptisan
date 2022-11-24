# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class SIProcessor
              SI                 = DigitalizedReceipt::Record::SI
              ShinryouKoui       = Receipt::Tekiyou::Resource::ShinryouKoui
              MasterShinryouKoui = Master::Treatment::ShinryouKoui

              # @param handler [MasterHandler]
              def initialize(handler)
                @handler = handler
              end

              # @param values [Array<String, nil>] SI行
              # @return [Receipt::Tekiyou::Resource::ShinryouKoui]
              def process(values)
                raise StandardError, 'line isnt SI record' unless values.first == 'SI'

                ShinryouKoui.new(
                  master_item: handler.find_by_code(
                    MasterShinryouKoui::Code.of(values[SI::C_レセ電コード])
                  ),
                  shiyouryou:  values[SI::C_数量データ]&.to_i
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
