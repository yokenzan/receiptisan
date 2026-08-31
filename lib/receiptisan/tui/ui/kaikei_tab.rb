# frozen_string_literal: true

module Receiptisan
  module Tui
    module Ui
      # 会計タブ: 保険情報・点数集計
      module KaikeiTab
        module_function

        # @param tui [RatatuiRuby::Session]
        # @param kaikei_lines [Array<Presenter::KaikeiLine>]
        # @param scroll_offset [Integer]
        # @return [RatatuiRuby::Widget]
        def build(tui, kaikei_lines, scroll_offset)
          visible_lines = kaikei_lines.drop(scroll_offset)

          spans = visible_lines.map do | line |
            if line.label.start_with?('==')
              tui.text_line(
                spans: [tui.text_span(content: line.label, style: tui.style(fg: :magenta, modifiers: [:bold]))]
              )
            elsif line.value.empty?
              tui.text_line(
                spans: [tui.text_span(content: "  #{line.label}")]
              )
            else
              tui.text_line(
                spans: [
                  tui.text_span(content: "  #{line.label}: ", style: tui.style(fg: :dark_gray)),
                  tui.text_span(content: line.value),
                ]
              )
            end
          end

          tui.paragraph(
            text:  spans,
            block: tui.block(
              title:   '会計',
              borders: [:all]
            )
          )
        end
      end
    end
  end
end
