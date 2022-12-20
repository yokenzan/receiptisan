# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        class Generator
          class TekiyouConvertor
            class TekiyouItemConvertor
              Common             = Receiptisan::Output::Preview::Parameter::Common
              DigitalizedReceipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt

              def initialize(resource_text_convertor)
                @resource_text_convertor = resource_text_convertor
              end

              # @param tekiyou_item [
              #   DigitalizedReceipt::Receipt::Tekiyou::Cost,
              #   DigitalizedReceipt::Receipt::Tekiyou::Comment
              # ]
              def convert(tekiyou_item)
                return Common::Comment.from(tekiyou_item) if tekiyou_item.comment?

                resource = tekiyou_item.resource

                Common::Cost.new(
                  type:       resource.type,
                  master:     {
                    type: resource.type,
                    code: resource.code.value,
                    name: resource.name,
                  },
                  text:       @resource_text_convertor.convert(resource),
                  unit:       resource.unit&.then { | u | Common::Unit.from(u) },
                  shiyouryou: resource.shiyouryou,
                  tensuu:     tekiyou_item.tensuu,
                  kaisuu:     tekiyou_item.kaisuu
                )
              end
            end
          end
        end
      end
    end
  end
end
