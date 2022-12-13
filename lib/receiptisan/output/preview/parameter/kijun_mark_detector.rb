# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        # 食事・生活療養の基準ローマ数字
        #
        # > [診療報酬請求書等の記載要領](https://www.mhlw.go.jp/content/12404000/000984055.pdf#page=42)
        # >
        # > (22) 「食事・生活」欄について
        # >
        # > ア 「基準」の項には、入院時食事療養費に係る食事療養について算定した項目について次の略号を用いて記載すること。
        # > ただし、複数の食事療養を算定し、「基準」の項に複数の略号を記載することが困難な場合は、「摘要」欄への記載でも差し支えないこと。
        # > Ⅰ（入院時食事療養Ⅰ(1)）、Ⅱ（入院時食事療養Ⅱ(1)）、Ⅲ（入院時食事療養Ⅰ(2)）、Ⅳ（入院時食事療養Ⅱ(2)）
        # >
        # > オ 「基準（生）」の項には、入院時生活療養費に係る生活療養について算定した項目を次の略号を用いて記載すること。
        # > ただし、複数の生活療養を算定し、「基準（生）」の項に複数の略号を記載することが困難な場合は、「摘要」欄への記載でも差し支えないこと。
        # > Ⅰ（入院時生活療養Ⅰ(1)イ）、Ⅱ（入院時生活療養Ⅱ）、Ⅲ（入院時生活療養Ⅰ(1)ロ）
        class KijunMarkDetector
          EnumeratorGenerator = Receiptisan::Model::ReceiptComputer::Util::ReceiptEnumeratorGenerator
          DigitalizedReceipt  = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt
          TAG_KEYS            = %w[
            shokuji-kijun-category-i
            shokuji-kijun-category-ii
            shokuji-kijun-category-iii
            shokuji-kijun-category-iv
            seikatsu-kijun-category-i
            seikatsu-kijun-category-ii
            seikatsu-kijun-category-iii
          ].freeze

          # @param tag_handler [Receiptisan::Model::ReceiptComputer::Tag::Handler]
          def initialize(tag_handler)
            @tag_handler = tag_handler
          end

          # @param receipt [DigitalizedReceipt::Receipt]
          # @return [Hash<Symbol, Array<String>]
          def detect(receipt)
            tag_handler.prepare(receipt.shinryou_ym)

            tags        = TAG_KEYS.map { | tag_key | tag_handler.find_by_key(tag_key) }
            kijun_marks = Common::ShokujiSeikatsuKijunMarks.new(shokuji: [], seikatsu: [])

            # @param tag [Receiptisan::Model::ReceiptComputer::Tag::Tag]
            tags.each do | tag |
              # @param cost [DigitalizedReceipt::Receipt::Tekiyou::Cost]
              EnumeratorGenerator.cost_enum_from(receipt, *tag.shinryou_shikibetsu).map do | cost |
                warn '-----------'
                warn cost.resource.code.value.inspect
                warn cost.resource.name.inspect
                warn tag.code.inspect
                warn tag.label.inspect
                next unless tag.code.include?(cost.resource.code.value)

                (tag.key.to_s.include?('shokuji') ? kijun_marks.shokuji : kijun_marks.seikatsu) << tag.label
                break
              end
            end

            kijun_marks
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
