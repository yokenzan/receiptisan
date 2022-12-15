# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class TOProcessor
              include Context::ErrorContextReportable

              TO                 = DigitalizedReceipt::Record::TO
              TokuteiKizai       = Receipt::Tekiyou::Resource::TokuteiKizai
              MasterTokuteiKizai = Master::Treatment::TokuteiKizai

              # @param handler [MasterHandler]
              def initialize(logger:, context:, handler:)
                @handler = handler
                @logger  = logger
                @context = context
              end

              # @param values [Array<String, nil>] TO行
              # @return [Receipt::Tekiyou::Resource::TokuteiKizai]
              def process(values)
                raise StandardError, 'line isnt TO record' unless values.first == 'TO'

                TokuteiKizai.new(
                  master_item:  handler.find_by_code(code = MasterTokuteiKizai::Code.of(values[TO::C_レセ電コード])),
                  shiyouryou:   shiyouryou   = values[TO::C_使用量]&.to_f,
                  product_name: product_name = values[TO::C_商品名及び規格又はサイズ],
                  unit:         unit         = Master::Unit.find_by_code(values[TO::C_単位コード].to_i),
                  unit_price:   unit_price   = values[TO::C_単価]&.to_f
                )
              rescue Master::MasterItemNotFoundError => e
                report_error(e, context)

                TokuteiKizai.dummy(
                  code:         code,
                  shiyouryou:   shiyouryou,
                  product_name: product_name,
                  unit:         unit,
                  unit_price:   unit_price
                )
              end

              private

              attr_reader :handler, :logger, :context
            end
          end
        end
      end
    end
  end
end
