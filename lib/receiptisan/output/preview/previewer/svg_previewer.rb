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

          # minify 用の正規表現パターン

          # 値が nil のセル（データ未設定の点数欄等）は to_zenkaku / to_currency が空文字を返すため
          # テンプレートから <text ...></text> のような空要素が大量に生成される。これを除去する。
          EMPTY_TEXT_ELEMENT_PATTERN = %r{<text[^>]*></text>}
          # 罫線 path 統合対象: <path d="..." class="g1"/> 等の単純な形式のみマッチ
          SIMPLE_PATH_PATTERN = %r{\A<path d="([^"]*)" class="(g\d+)"\s*/>\z}

          # @param lib_version [String]
          # @param digitalized_receipts [Array<Parameter::Common::DigitalizedReceipt>]
          # @param output_content_styles [Hash<Symbol, String>] stylings for output receipts' contents
          # @return [String]
          def preview(lib_version, *digitalized_receipts, output_content_styles: {})
            @shoubyou_line_builder = LineBuilder::ShoubyouLineBuilder.new
            @tekiyou_line_builder  = LineBuilder::TekiyouLineBuilder.new
            @svg_of_receipts       = []

            digitalized_receipts.each do | digitalized_receipt |
              digitalized_receipt.receipts.each { | receipt | build_receipt_preview(receipt) }
            end

            # ERBテンプレートから生成されるHTMLはテンプレートの可読性を優先した構造のため
            # 冗長な空白・コメント・空要素を含む。minify で出力サイズを削減する。
            result = ERB.new(File.read(TEMPLATE_OUTLINE_PATH), trim_mode: '%>').result(binding)
            minify(result)
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

          # ERBテンプレート出力に対する後処理で出力サイズを削減する
          #
          # 以下の処理を適用する:
          #   1. 空の <text> 要素を除去
          #   2. 行頭インデント空白を除去
          #   3. 連続する空行を1行に圧縮
          #   4. 同一クラスの連続する <path> 要素の d 属性を結合
          #
          # コメントはテンプレート側で ERB コメント（<%# %>）を使用しているため
          # ERB 処理時に除去され、ここでの除去は不要。
          #
          # @param html [String] ERBテンプレートから生成されたHTML文字列
          # @return [String] 軽量化されたHTML文字列
          def minify(html)
            cleaned = html
              .gsub(EMPTY_TEXT_ELEMENT_PATTERN, '')
              .gsub(/^ +/, '')
              .squeeze("\n")

            merge_consecutive_paths(cleaned)
          end

          # 同一 CSS クラスの連続する <path> 要素を1つの要素に統合する
          #
          # レセプト用紙の罫線は多数の個別 <path> で表現されているが、
          # SVG の path d 属性は複数の M(moveto) コマンドを連結できるため、
          # 同一クラス（= 同一線種）の連続する path を1要素にまとめてタグのオーバーヘッドを削減する。
          #
          # 対象は `<path d="..." class="gN"/>` の単純な形式のみ。
          # fill や stroke 等の追加属性を持つ path は統合しない。
          #
          # @param html [String]
          # @return [String]
          def merge_consecutive_paths(html)
            lines  = html.lines
            result = []
            i      = 0

            while i < lines.length
              line = lines[i].chomp

              if (m = line.match(SIMPLE_PATH_PATTERN))
                # 統合対象の path を検出。同一クラスが続く限り d 属性値を収集する
                d_parts = [m[1]]
                klass   = m[2]

                while i + 1 < lines.length &&
                      (m2 = lines[i + 1].chomp.match(SIMPLE_PATH_PATTERN)) &&
                      m2[2] == klass
                  d_parts << m2[1]
                  i += 1
                end

                # 収集した d 値をスペース区切りで連結し、1つの path 要素として出力
                result << %(<path d="#{d_parts.join(' ')}" class="#{klass}"/>\n)
              else
                result << lines[i]
              end

              i += 1
            end

            result.join
          end

          # テンプレートエンジンによるプレビューレンダリング中に呼び出すヘルパ

          # 低所得区分をレセプトに出力するか？
          #
          # @param receipt [Receiptisan::Output::Preview::Parameter::Common::Receipt]
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
