# frozen_string_literal: true

module Receiptisan
  module Tui
    module Ui
      # 摘要タブ: 診療識別グループ + 色分け表示
      module TekiyouTab
        # 項目種別ごとの色
        RESOURCE_COLORS = {
          shinryou_koui: :white,
          iyakuhin:      :cyan,
          tokutei_kizai: :green,
          comment:       :yellow,
          header:        :magenta,
          tensuu:        :dark_gray,
          spacer:        nil,
        }.freeze

        module_function

        # @param tui [RatatuiRuby::Session]
        # @param tekiyou_lines [Array<Presenter::TekiyouLine>]
        # @param scroll_offset [Integer]
        # @return [RatatuiRuby::Widget]
        def build(tui, tekiyou_lines, scroll_offset)
          visible_lines = tekiyou_lines.drop(scroll_offset)

          spans = visible_lines.map do | line |
            color = RESOURCE_COLORS[line.resource_type]
            indent = ' ' * line.indent
            text = "#{indent}#{line.text}"

            if color
              tui.text_line(
                spans: [tui.text_span(content: text, style: tui.style(fg: color))]
              )
            else
              tui.text_line(spans: [tui.text_span(content: text)])
            end
          end

          tui.paragraph(
            text:  spans,
            block: tui.block(
              title:   '摘要',
              borders: [:all]
            )
          )
        end
      end
    end
  end
end
