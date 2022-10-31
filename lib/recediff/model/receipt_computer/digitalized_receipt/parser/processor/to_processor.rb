# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class TOProcessor
              TO = DigitalizedReceipt::Record::TO

              # @param handler [MasterHandler]
              def initialize(handler)
                @handler = handler
              end

              # @param values [Array<String, nil>] TO行
              # @return [Receipt::ShinryouKoui]
              def process(values)
                raise StandardError, 'line isnt TO record' unless values.first == 'TO'

                Receipt::TokuteiKizai.new(
                  master_tokutei_kizai: handler.find_by_code(Master::TokuteiKizaiCode.of(values[TO::C_レセ電コード])),
                  shiyouryou:           values[TO::C_使用量]&.to_f,
                  product_name:         values[TO::C_商品名及び規格又はサイズ]
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
