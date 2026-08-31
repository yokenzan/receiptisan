# frozen_string_literal: true

module Receiptisan
  module Tui
    module Ui
      # 2ペインレイアウト定義
      module Layout
        LEFT_PANE_PERCENT  = 35
        RIGHT_PANE_PERCENT = 65
        HEADER_HEIGHT      = 6
        TAB_BAR_HEIGHT     = 3
        STATUS_BAR_HEIGHT  = 1

        module_function

        # @param tui [RatatuiRuby::Session]
        # @param area [RatatuiRuby::Rect]
        # @return [Hash] :left, :right_header, :right_tab_bar, :right_content, :status_bar
        def split(tui, area)
          # メインエリアとステータスバー
          main_area, status_bar = tui.layout_split(
            area,
            direction:   :vertical,
            constraints: [
              tui.constraint_fill(1),
              tui.constraint_length(STATUS_BAR_HEIGHT),
            ]
          )

          # 左ペインと右ペイン
          left, right = tui.layout_split(
            main_area,
            direction:   :horizontal,
            constraints: [
              tui.constraint_percentage(LEFT_PANE_PERCENT),
              tui.constraint_percentage(RIGHT_PANE_PERCENT),
            ]
          )

          # 右ペイン: ヘッダー + タブバー + コンテンツ
          right_header, right_tab_bar, right_content = tui.layout_split(
            right,
            direction:   :vertical,
            constraints: [
              tui.constraint_length(HEADER_HEIGHT),
              tui.constraint_length(TAB_BAR_HEIGHT),
              tui.constraint_fill(1),
            ]
          )

          {
            left:          left,
            right_header:  right_header,
            right_tab_bar: right_tab_bar,
            right_content: right_content,
            status_bar:    status_bar,
          }
        end
      end
    end
  end
end
