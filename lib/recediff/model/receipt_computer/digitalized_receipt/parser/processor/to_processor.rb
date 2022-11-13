# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class TOProcessor
              TO                 = DigitalizedReceipt::Record::TO
              TokuteiKizai       = Receipt::Tekiyou::Cost::TokuteiKizai
              MasterTokuteiKizai = Master::Treatment::TokuteiKizai

              # @param handler [MasterHandler]
              def initialize(handler)
                @handler = handler
              end

              # @param values [Array<String, nil>] TO行
              # @return [Receipt::Tekiyou::Cost::TokuteiKizai]
              def process(values)
                raise StandardError, 'line isnt TO record' unless values.first == 'TO'

                TokuteiKizai.new(
                  master_tokutei_kizai: handler.find_by_code(MasterTokuteiKizai::Code.of(values[TO::C_レセ電コード])),
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
