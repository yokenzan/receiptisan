# frozen_string_literal: true

module Receiptisan
  module Tui
    # TUI アプリケーションの状態管理
    class State
      TABS = %i[tekiyou kaikei].freeze

      attr_reader :selected_index, :active_tab, :tab_scroll_offset, :receipt_count

      # @param receipt_count [Integer]
      def initialize(receipt_count)
        @receipt_count     = receipt_count
        @selected_index    = 0
        @active_tab        = :tekiyou
        @tab_scroll_offset = 0
      end

      # @param delta [Integer]
      def move_selection(delta)
        return if @receipt_count.zero?

        new_index = @selected_index + delta
        new_index = new_index.clamp(0, @receipt_count - 1)
        return if new_index == @selected_index

        @selected_index    = new_index
        @tab_scroll_offset = 0
      end

      def select_first
        return if @selected_index.zero?

        @selected_index    = 0
        @tab_scroll_offset = 0
      end

      def select_last
        return if @receipt_count.zero?

        last = @receipt_count - 1
        return if @selected_index == last

        @selected_index    = last
        @tab_scroll_offset = 0
      end

      def toggle_tab
        @active_tab        = @active_tab == :tekiyou ? :kaikei : :tekiyou
        @tab_scroll_offset = 0
      end

      # @param delta [Integer]
      def scroll_tab(delta)
        new_offset = @tab_scroll_offset + delta
        @tab_scroll_offset = [new_offset, 0].max
      end
    end
  end
end
