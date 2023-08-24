# frozen_string_literal: true

require 'erb'

module Receiptisan
  module Output
    module Preview
      module Previewer
        class SVGPreviewer
          include Receiptisan::Util::Formatter

          LineBuilder              = Receiptisan::Output::Preview::LineBuilder
          HokenOrder               = Model::ReceiptComputer::DigitalizedReceipt::Receipt::FutanKubun::HokenOrder
          TEMPLATE_OUTLINE_PATH    = __dir__ + '/../../../../../views/receipt/outline.html.erb'
          TEMPLATE_FRONT_PATH      = __dir__ + '/../../../../../views/receipt/format-front.svg.erb'
          TEMPLATE_NEXT_PATH       = __dir__ + '/../../../../../views/receipt/format-next.svg.erb'

          # @param digitalized_receipts [Array<Parameter::Common::DigitalizedReceipt>]
          # @param output_content_styles [Hash<Symbol, String>] stylings for output receipts' contents
          # @return [String]
          def preview(*digitalized_receipts, output_content_styles: {})
            @shoubyou_line_builder = LineBuilder::ShoubyouLineBuilder.new
            @tekiyou_line_builder  = LineBuilder::TekiyouLineBuilder.new
            @svg_of_receipts       = []

            digitalized_receipts.each do | digitalized_receipt |
              digitalized_receipt.receipts.each { | receipt | build_receipt_preview(receipt) }
            end

            ERB.new(File.read(TEMPLATE_OUTLINE_PATH), trim_mode: '%>').result(binding)
          end

          private

          # @param receipt [Parameter::Common::Receipt]
          def build_receipt_preview(receipt)
            @tekiyou_line_builder.retrieve_attr_from_receipt(receipt)

            # 傷病欄行

            shoubyou_result = build_shoubyou_lines(receipt)
            shoubyou_lines  = shoubyou_result.lines

            # 摘要欄行

            build_tekiyou_lines(shoubyou_result, receipt)

            # レンダリング

            @svg_of_receipts << []

            # 表紙
            tekiyou_page = @tekiyou_line_builder.next_page
            @svg_of_receipts.last << ERB.new(File.read(TEMPLATE_FRONT_PATH), trim_mode: '%>').result(binding)

            # 続紙
            while @tekiyou_line_builder.page_length.positive?
              tekiyou_page_left  = @tekiyou_line_builder.next_page
              tekiyou_page_right = @tekiyou_line_builder.next_page
              # 空のページがつくられていることがあるので、空か判定している
              break if tekiyou_page_left.empty?

              @svg_of_receipts.last << ERB.new(File.read(TEMPLATE_NEXT_PATH), trim_mode: '%>').result(binding)
            end
          end

          # 患者傷病名を傷病欄行に変換する
          #
          # @param digitalized_receipt [Parameter::Common::Receipt]
          # @return [ShoubyouLineBuilder::Result]
          def build_shoubyou_lines(receipt)
            @shoubyou_line_builder.build(receipt.shoubyoumeis)
          end

          # @param digitalized_receipt [Parameter::Common::Receipt]
          # @return [void]
          def build_tekiyou_lines(shoubyou_result, receipt)
            # 欄外に溢れる傷病名は摘要欄行に変換する
            shoubyou_result.has_more && @tekiyou_line_builder.build_shoubyoumei_groups(shoubyou_result)

            # 公費欄を溢れる第三公費・第四公費は摘要欄行に変換する
            if receipt.hokens.kouhi_futan_iryous.length > 2
              receipt.hokens.kouhi_futan_iryous[2..].each_index do | index |
                kouhi  = receipt.hokens.kouhi_futan_iryous[2 + index]
                kyuufu = receipt.ryouyou_no_kyuufu.kouhi_futan_iryous[2 + index]

                @tekiyou_line_builder.build_kouhi_futan_iryou(kouhi, kyuufu, index)
              end
            end

            # コストを摘要欄行に変換する
            receipt.tekiyou.shinryou_shikibetsu_sections.each do | section |
              @tekiyou_line_builder.build_shinryou_shikibetsu_section(
                section.shinryou_shikibetsu,
                section.ichiren_units
              )
            end
          end

          # 低所得区分をレセプトに出力するか？
          #
          # @param digitalized_receipt [Parameter::Common::Receipt]
          def should_print_teishotoku_type?(receipt)
            return false unless receipt.hokens.iryou_hoken&.teishotoku_type

            %i[kouki_ippan kourei_ippan].include?(receipt.classification)
          end

          # @return [HokenOrder]
          def iryou_hoken_order
            HokenOrder.iryou_hoken
          end

          # @return [HokenOrder]
          def kouhi_1st_order
            HokenOrder.kouhi_futan_iryou(0)
          end

          # @override
          def to_zenkaku(value)
            Receiptisan::Util::Formatter
              .to_zenkaku(value)
              .gsub(LineBuilder::TekiyouLineBuilder::ZENKAKU_SPACE, '&emsp;')
          end

          def nyuuin?(receipt)
            receipt.nyuugai == :nyuuin
          end
        end
      end
    end
  end
end
