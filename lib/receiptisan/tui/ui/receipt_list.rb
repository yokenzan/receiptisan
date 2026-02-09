# frozen_string_literal: true

module Receiptisan
  module Tui
    module Ui
      # 左ペイン: レセプト一覧ウィジェット
      module ReceiptList
        module_function

        # @param tui [RatatuiRuby::Session]
        # @param list_items [Array<Presenter::ListItem>]
        # @param selected_index [Integer]
        # @return [RatatuiRuby::Widget]
        def build(tui, list_items, selected_index)
          items = list_items.map(&:label)

          tui.list(
            items:            items,
            selected_index:   selected_index,
            highlight_style:  tui.style(fg: :white, bg: :blue, modifiers: [:bold]),
            highlight_symbol: '> ',
            scroll_padding:   2,
            block:            tui.block(
              title:   'レセプト一覧',
              borders: [:all]
            )
          )
        end
      end
    end
  end
end
