# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        # 病床区分欄
        class ByoushouTypeDetector
          EnumeratorGenerator = Receiptisan::Model::ReceiptComputer::Util::ReceiptEnumeratorGenerator
          DigitalizedReceipt  = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt
          TAG_NAMES           = %w[byoushou-type-ryouyou].freeze

          # @param tag_handler [Receiptisan::Model::ReceiptComputer::Tag::Handler]
          def initialize(tag_handler)
            @tag_handler = tag_handler
            @tags        = []
          end

          # @param receipt [DigitalizedReceipt::Receipt]
          def detect(receipt)
            initialize_tags(receipt.shinryou_ym)
            byoushou_type_labels = []

            # @param tag [Receiptisan::Model::ReceiptComputer::Tag::Tag]
            @tags.each do | tag |
              # @param cost [DigitalizedReceipt::Receipt::Tekiyou::Cost]
              EnumeratorGenerator.cost_enum_from(receipt, *tag.shinryou_shikibetsu).map do | cost |
                next unless tag.code.include?(cost.resource.code.value)

                byoushou_type_labels << tag.label
                break
              end
            end

            byoushou_type_labels.sort_by(&:to_s)
          end

          # @param year_month [Month]
          def initialize_tags(year_month)
            tag_handler.prepare(year_month)
            @tags = TAG_NAMES.map { | tag_name | tag_handler.find_by_name(tag_name) }
          end

          private

          # @!attribute [r] tag_handler
          #   @return [Receiptisan::Model::ReceiptComputer::Tag::Handler]
          attr_reader :tag_handler
        end
      end
    end
  end
end
