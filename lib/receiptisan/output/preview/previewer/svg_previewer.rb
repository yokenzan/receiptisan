# frozen_string_literal: true

require 'erb'

module Receiptisan
  module Output
    module Preview
      module Previewer
        class SVGPreviewer
          TEMPLATE_PATH = __dir__ + '/../../../../../views/receipt/format-nyuuin-new.svg'

          # @param digitalized_receipt [Parameter::Common::DigitalizedReceipt]
          def preview(digitalized_receipt)
            preview_receipt(digitalized_receipt.receipts[58])
          end

          # @param digitalized_receipt [Parameter::Common::Receipt]
          def preview_receipt(receipt)
            shoubyou_line_builder = ShoubyouLineBuilder.new
            tekiyou_line_builder  = TekiyouLineBuilder.new

            # 患者傷病名を傷病欄行に変換する

            shoubyou_result = shoubyou_line_builder.build(receipt.shoubyoumeis)

            # 欄外に溢れる傷病名は摘要欄行に変換する

            if shoubyou_result.has_more
              shoubyou_result.rest.each_with_index do | group, index |
                tekiyou_line_builder.build_shoubyoumei_group(
                  group, shoubyou_result.target.length + index
                )
              end
            end

            # 公費欄を溢れる第三公費・第四公費は摘要欄行に変換する

            if receipt.hokens.kouhi_futan_iryous.length > 2
              receipt.hokens.kouhi_futan_iryous[2..].each_index do | index |
                kouhi  = receipt.hokens.kouhi_futan_iryous[2 + index]
                kyuufu = receipt.ryouyou_no_kyuufu.kouhi_futan_iryous[2 + index]

                tekiyou_line_builder.build_kouhi_futan_iryou(kouhi, kyuufu, index)
              end
            end

            # コストを摘要欄行に変換する

            receipt.tekiyou.shinryou_shikibetsu_sections.each do | section |
              tekiyou_line_builder.build_shinryou_shikibetsu_section(
                section.shinryou_shikibetsu,
                section.ichiren_units
              )
            end

            puts tekiyou_line_builder.build

            # puts ERB.new(File.read(TEMPLATE_PATH)).result(binding)
          end

          def to_zenkaku(number)
            number.to_s.tr('0-9.', '０-９．')
          end

          # 傷病名欄行の生成
          class ShoubyouLineBuilder
            def initialize(max_line_length: 78, max_line_count: 5)
              @max_line_length = max_line_length
              @max_line_count  = max_line_count
              @delimitor       = '，'
            end

            def build(shoubyoumei_groups)
              @current_line_count = 0
              @result             = Result.new(
                lines:    [],
                has_more: false,
                target:   [],
                rest:     []
              )

              shoubyoumei_groups.each_with_index do | group, group_index |
                built = build_shoubyoumei_group(group, group_index)

                if built.nil?
                  @result.rest     = shoubyoumei_groups[group_index..]
                  @result.has_more = true
                  break
                end

                @result.target << group
                @result.lines.concat(built)
              end

              @result
            end

            private

            def build_shoubyoumei_group(group, group_index)
              names_for_lines = build_name_lines(group, group_index)

              @current_line_count += names_for_lines.length

              return if @current_line_count > @max_line_count

              names_for_lines.map.with_index do | names, index |
                ShoubyouLine.new(
                  name:       names,
                  start_date: index.zero? ? group.start_date.wareki.text : nil,
                  tenki:      index.zero? ? group.tenki.name             : nil
                )
              end
            end

            def build_name_lines(group, group_index)
              group.shoubyoumeis
                .map(&:full_text)
                .each_with_object([generate_rounded_number_mark(group_index)]) do | name, names_for_lines |
                  names_for_lines << '' + '　' if (names_for_lines.last + name).length > @max_line_length
                  names_for_lines.last.concat(names_for_lines.last.length == 1 ? '' : @delimitor, name)
                end
            end

            # マル付数字の文字を生成する
            def generate_rounded_number_mark(index)
              (0x2460 + index).chr('UTF-8') # ①
            end

            attr_writer :max_line_length, :max_line_count, :delimitor

            ShoubyouLine = Struct.new(:name, :start_date, :tenki, keyword_init: true)
            Result       = Struct.new(:target, :lines, :has_more, :rest, keyword_init: true)
          end

          # 摘要欄行の生成
          # rubocop:disable Style/ClassLength
          class TekiyouLineBuilder
            ZENKAKU_SPACE = '　'
            ASTERISK      = '＊'
            COMMA         = '，'

            def initialize(max_line_length: 25, max_line_count: 36)
              @max_line_length = max_line_length
              @max_line_count  = max_line_count
              @indent_width    = 1
              @buffer          = []
              @temp_lines      = []
              @current_line    = nil
              clear_state
            end

            def build
              lines = buffer
              clear_state
              lines
            end

            # @return [void]
            def build_shoubyoumei_group(shoubyoumei_group, group_index)
              new_current_line_with(generate_rounded_number_mark(group_index))

              shoubyoumei_group.shoubyoumeis.map(&:full_text).each do | shoubyou_name |
                if [current_line.text, shoubyou_name].reject(&:empty?).join(COMMA).length > @max_line_length
                  stack_to_temp
                  new_current_line
                end

                current_line.text.concat(COMMA) if current_line.text.length > 1
                current_line.text.concat(shoubyou_name)
              end

              start_date_and_tenki = [
                shoubyoumei_group.start_date.wareki.text,
                shoubyoumei_group.tenki.name,
              ].join(ZENKAKU_SPACE)

              append_or_new_line(start_date_and_tenki, rjust_if_new_line: true)

              flush_temp_lines
            end

            def build_kouhi_futan_iryou(kouhi, kyuufu, _index)
              new_current_line_with('第三公費') # TODO
              stack_to_temp

              new_current_line_with('負担者番号　%s' % to_zenkaku(kouhi.futansha_bangou))
              stack_to_temp

              new_current_line_with('受給者番号　%s' % to_zenkaku(kouhi.jukyuusha_bangou))
              stack_to_temp

              new_current_line_with('実日数　　　%s日' % to_zenkaku(kyuufu.shinryou_jitsunissuu))
              stack_to_temp

              flush_temp_lines
            end

            def build_shinryou_shikibetsu_section(shinryou_shikibetsu, ichiren_units)
              ichiren_units.each_with_index do | ichiren_unit, ichiren_index |
                ichiren_unit.santei_units.each_with_index do | santei_unit, santei_index |
                  santei_unit.items.each_with_index do | item, item_index |
                    new_current_line(
                      shinryou_shikibetsu: [ichiren_index, santei_index, item_index].all?(&:zero?) ?
                        shinryou_shikibetsu.code :
                        nil,
                      futan_kubun:         item_index.zero? ? ichiren_unit.futan_kubun : nil,
                      requires_asterisk:   item_index.zero?
                    )
                    build_tekiyou_item(item)
                  end
                end
              end

              flush_temp_lines
            end

            private

            attr_reader :current_line, :temp_lines, :buffer

            def build_tekiyou_item(item)
              item_text = item.text

              # コメントの場合の処理

              if item.type == :comment
                slice_to_lines(item_text, break_at_last_line: true)
                # コメントの場合の処理はここでおしまい
                return
              end

              # コストの場合の処理

              if (product_name = item_text.product_name)
                slice_to_lines(product_name, break_at_last_line: true)
              end

              # 名称, 単価, 使用量, 点数×回数の表記は、字数が許せばなるべく一行で
              # 表現する

              slice_to_lines(item_text.master_name, break_at_last_line: true)

              if (unit_price = item_text.unit_price)
                append_or_new_line(unit_price)
              end

              if (shiyouryou = item_text.shiyouryou)
                append_or_new_line(shiyouryou)
              end

              if (kaisuu_and_tensuu = tensuu_text(item))
                append_or_new_line(kaisuu_and_tensuu, rjust_if_new_line: true)
              end

              stack_to_temp
            end

            def slice_to_lines(text, break_at_last_line: false)
              each_slice_by_line_length(text) do | partial_text, index, is_last |
                new_current_line unless index.zero?
                current_line.text.concat(partial_text)
                break if break_at_last_line && is_last

                stack_to_temp
              end
            end

            def each_slice_by_line_length(string)
              string = string.dup
              index  = 0

              loop do
                yield string.slice!(0, @max_line_length - @indent_width), index, _is_last = string.empty?
                index += 1
                break if string.empty?
              end
            end

            def append_or_new_line(text, rjust_if_new_line: false, indent: false)
              max_line_length = @max_line_length - (indent ? 1 : 0)

              if [current_line.text, text].join(ZENKAKU_SPACE).length > max_line_length
                stack_to_temp
                new_current_line
              end

              current_line.text.concat(
                rjust_if_new_line ?
                  text.rjust(max_line_length - current_line.text.length, ZENKAKU_SPACE) :
                  ZENKAKU_SPACE + text
              )
            end

            def new_current_line(shinryou_shikibetsu: nil, futan_kubun: nil, requires_asterisk: false)
              @current_line = TekiyouLine.new(
                shinryou_shikibetsu: shinryou_shikibetsu,
                futan_kubun:         futan_kubun,
                text:                '' + (requires_asterisk ? ASTERISK : ZENKAKU_SPACE)
              )
            end

            def new_current_line_with(text)
              @current_line = TekiyouLine.new(shinryou_shikibetsu: nil, futan_kubun: nil, text: text)
            end

            def stack_to_temp
              return unless @current_line
              return if @current_line.empty?

              @temp_lines << @current_line

              @current_line = nil
            end

            def tensuu_text(item)
              tensuu = item.tensuu
              kaisuu = item.kaisuu

              return '' if tensuu.nil? || kaisuu.nil?

              to_zenkaku('%d x %2d' % [tensuu, kaisuu])
            end

            def generate_rounded_number_mark(index)
              (0x2460 + index).chr('UTF-8')
            end

            def to_zenkaku(number)
              number.to_s.tr('−() A-Za-z0-9.', 'ー（）　Ａ-Ｚａ-ｚ０-９．')
            end

            # @return [void]
            def flush_temp_lines
              last_line = buffer.last
              if last_line && last_line.text != '－' * @max_line_length
                buffer << TekiyouLine.new(
                  shinryou_shikibetsu: nil,
                  futan_kubun:         nil,
                  text:                '－' * @max_line_length
                )
              end

              stack_to_temp
              buffer.concat(@temp_lines)
              @temp_lines.clear
            end

            # @return [void]
            def clear_state
              @buffer       = []
              @temp_lines   = []
              @current_line = nil
            end

            TekiyouLine = Struct.new(
              :shinryou_shikibetsu,
              :futan_kubun,
              :text,
              keyword_init: true
            ) do
              def empty?
                values.compact.empty?
              end

              def to_s
                [
                  shinryou_shikibetsu || ZENKAKU_SPACE,
                  futan_kubun || ' ',
                  text,
                ].join('｜')
              end
            end
          end
          # rubocop:enable Style/ClassLength
        end
      end
    end
  end
end
