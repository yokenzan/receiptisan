# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Output
    module Preview
      module LineBuilder
        # 摘要欄行の生成
        #
        # TODO: 状態をもっているのでステートレスにしたい
        #
        # rubocop:disable Metrics/ClassLength
        class TekiyouLineBuilder
          include Receiptisan::Util::Formatter

          ZENKAKU_SPACE = '　'
          ASTERISK      = '＊'
          COMMA         = '，'
          SEPARATOR     = '―'

          def initialize(
            max_line_length:       27,
            max_line_count_nyuuin: 36,
            max_line_count_gairai: 42,
            max_line_count_next:   71
          )
            @max_line_length       = max_line_length
            @max_line_count_nyuuin = max_line_count_nyuuin
            @max_line_count_gairai = max_line_count_gairai
            @max_line_count_next   = max_line_count_next
            @indent_width          = 1
            @buffer_per_pages      = []
            @temp_lines            = []
            @current_line          = nil
            clear_state
          end

          # @return [TekiyouPage, nil]
          def next_page
            @buffer_per_pages.shift
          end

          # @return [void]
          def build_shoubyoumei_groups(shoubyou_result)
            shoubyou_result.rest.each_with_index do | group, index |
              build_shoubyoumei_group(
                group, shoubyou_result.target.length + index
              )
            end

            flush_temp_lines
          end

          def build_kouhi_futan_iryou(kouhi, kyuufu, index)
            number = '三四五六七八九'[index]
            new_current_line_with('＜第%s公費＞' % number) # TODO

            format = '%-9s　%s%s'

            new_current_line_with(format % ['負担者番号', kouhi.futansha_bangou, ''], stack_in_advance: true)

            new_current_line_with(format % ['受給者番号', kouhi.jukyuusha_bangou, ''], stack_in_advance: true)

            new_current_line_with(format % ['実日数', kyuufu.shinryou_jitsunissuu, '日'], stack_in_advance: true)

            new_current_line_with(format % ['合計点数', to_currency(kyuufu.goukei_tensuu), '点'], stack_in_advance: true)

            new_current_line_with(format % ['一部負担金', to_currency(kyuufu.ichibu_futankin), '円'], stack_in_advance: true)
            stack_to_temp

            if kyuufu.kyuufu_taishou_ichibu_futankin
              new_current_line_with(format % ['給付対象一部負担金', to_currency(kyuufu.kyuufu_taishou_ichibu_futankin), '円'])
              stack_to_temp
            end

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
              # 一連行為単位ごとに変換データをページオブジェクトにフラッシュしていくが、
              # 仕切り線は診療識別セクションの仕切りとして引くものなので、基本的には
              # never_separator: true を渡してフラッシュ時の仕切り線の挿入を抑制する
              #
              # 診療識別最初の一連行為単位の場合のみ、仕切り線を挿入してもらうようにする
              flush_temp_lines(never_separator: ichiren_index.positive?)
            end

            flush_temp_lines
          end

          # @return [void]
          def clear_state
            @buffer_per_pages     = []
            @temp_lines           = []
            @current_line         = nil
            @current_receipt_attr = nil
          end

          # @return [Integer]
          def page_length
            @buffer_per_pages.length
          end

          # @param receipt [Receiptisan::Output::Preview::Parameter::Common::Receipt]
          # @return [void]
          def retrieve_attr_from_receipt(receipt)
            @current_receipt_attr = ReceiptAttr.from_receipt(receipt)
          end

          private

          attr_reader :current_line, :temp_lines, :current_receipt_attr

          # @return [void]
          def build_shoubyoumei_group(shoubyoumei_group, group_index)
            new_current_line_with(to_marutsuki_mark(group_index))

            shoubyoumei_group
              .shoubyoumeis
              .map(&:full_text)
              .each do | shoubyou_name |
                if [current_line.text, shoubyou_name].reject(&:empty?).join(COMMA).length > @max_line_length
                  current_line.text << COMMA
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

            stack_to_temp
          end

          def build_tekiyou_item(item)
            item_text = item.text

            # コメントの場合の処理

            if item.type == :comment
              slice_to_lines(item_text)
              # コメントの場合の処理はここでおしまい
              return
            end

            # コストの場合の処理

            # 特定器材の製品名
            # 名称との間に必ず改行をはさむ
            if (product_name = item_text.product_name)
              slice_to_lines(product_name)
              new_current_line
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

          def new_current_line_with(text, stack_in_advance: false)
            stack_to_temp if stack_in_advance

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

            '%d×%2d' % [tensuu, kaisuu]
          end

          # @return [void]
          def flush_temp_lines(never_separator: false)
            bottom_line = current_page.last

            if never_separator == false && bottom_line && !bottom_line.separator?
              current_page.add(TekiyouLine.new(
                shinryou_shikibetsu: nil,
                futan_kubun:         nil,
                text:                SEPARATOR * @max_line_length
              ))
            end

            stack_to_temp

            new_page if (current_page + @temp_lines).length > detect_max_line_count

            current_page.concat(@temp_lines)

            @temp_lines.clear
          end

          # 現在のページ最大行数の判定
          # @return [Integer]
          def detect_max_line_count
            # フラッシュ先が表紙か続紙かを pages.length で判定している
            return @max_line_count_next if page_length > 1

            @current_receipt_attr.nyuuin? ? @max_line_count_nyuuin : @max_line_count_gairai
          end

          # @return [void]
          def new_page
            @buffer_per_pages << TekiyouPage.new
          end

          # @return [TekiyouPage]
          def current_page
            new_page if @buffer_per_pages.empty?
            @buffer_per_pages.last
          end

          # 摘要欄のページ
          #
          # 表紙は1枚1ページ / 続紙は左右あわせて2ページ
          class TekiyouPage
            extend Forwardable

            # def initialize(max_line_length: , max_line_count:)
            def initialize
              @lines = []
            end

            # @param line [TekiyouLine]
            # @return [void]
            def add(line)
              @lines << line
            end

            # @param lines [TekiyouLine]
            # @return [void]
            def concat(*lines)
              @lines.concat(*lines)
            end

            def +(other)
              self.class.new.tap do | page |
                page.concat(@lines)
                page.concat(other)
              end
            end

            def_delegators :@lines, :each, :each_with_index, :empty?, :last, :length
          end

          # 摘要欄行
          class TekiyouLine
            def initialize(shinryou_shikibetsu:, futan_kubun:, text:)
              @shinryou_shikibetsu = shinryou_shikibetsu
              @futan_kubun         = futan_kubun
              @text                = text
            end

            def empty?
              [shinryou_shikibetsu, futan_kubun, text].compact.empty?
            end

            def separator?
              text.squeeze == TekiyouLineBuilder::SEPARATOR
            end

            def to_s
              [
                shinryou_shikibetsu || ZENKAKU_SPACE,
                futan_kubun || ' ',
                text,
              ].join('｜')
            end

            # @!attribute [rw] shinryou_shikibetsu
            #   @return [String, nil]
            # @!attribute [rw] futan_kubun
            #   @return [String, nil]
            # @!attribute [rw] text
            #   @return [String, nil]
            attr_accessor :shinryou_shikibetsu, :futan_kubun, :text
          end

          class ReceiptAttr
            class << self
              # @param receipt [Receiptisan::Output::Preview::Parameter::Common::Receipt]
              # @return [ReceiptAttr]
              def from_receipt(receipt)
                new(nyuugai: receipt.nyuugai)
              end
            end

            def initialize(nyuugai:)
              @nyuugai = nyuugai
            end

            def nyuuin?
              @nyuugai == :nyuuin
            end

            # @!attribute [r] nyuugai
            #   @return [Symbol]
            attr_reader :nyuugai
          end
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
