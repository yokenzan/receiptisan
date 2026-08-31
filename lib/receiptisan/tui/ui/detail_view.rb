# frozen_string_literal: true

module Receiptisan
  module Tui
    module Ui
      # 右ペイン: ヘッダー + タブバー
      module DetailView
        module_function

        # @param tui [RatatuiRuby::Session]
        # @param header_data [Presenter::HeaderData, nil]
        # @return [RatatuiRuby::Widget]
        def build_header(tui, header_data)
          text = if header_data
                   lines = [header_data.patient_line, header_data.type_line]
                   lines << header_data.tokki_line if header_data.tokki_line
                   lines << header_data.nyuuin_line if header_data.nyuuin_line
                   lines.join("\n")
                 else
                   ''
                 end

          tui.paragraph(
            text:  text,
            block: tui.block(
              title:   '詳細',
              borders: [:all]
            )
          )
        end

        # @param tui [RatatuiRuby::Session]
        # @param active_tab [Symbol]
        # @return [RatatuiRuby::Widget]
        def build_tab_bar(tui, active_tab)
          selected = active_tab == :tekiyou ? 0 : 1

          tui.tabs(
            titles:          %w[摘要 会計],
            selected_index:  selected,
            highlight_style: tui.style(fg: :yellow, modifiers: [:bold]),
            block:           tui.block(borders: [:all])
          )
        end
      end
    end
  end
end
