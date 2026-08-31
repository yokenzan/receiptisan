# frozen_string_literal: true

require 'ratatui_ruby'

module Receiptisan
  module Tui
    # メインアプリケーション: ターミナル初期化・イベントループ・描画
    class Application
      STATUS_TEXT = ' q:終了  j/k:選択  g/G:先頭/末尾  Tab:タブ切替  J/K:内容スクロール '

      # @param digitalized_receipts [Array<Model::ReceiptComputer::DigitalizedReceipt>]
      def initialize(digitalized_receipts)
        @receipts  = digitalized_receipts.flat_map(&:to_a)
        @presenter = Presenter.new
        @state     = State.new(@receipts.length)
      end

      def run
        @list_items = @presenter.list_items(@receipts)

        RatatuiRuby.run do | tui |
          loop do
            draw(tui)
            break if handle_event(tui) == :quit
          end
        end
      end

      private

      # @param tui [RatatuiRuby::Session]
      def draw(tui)
        tui.draw do | frame |
          areas = Ui::Layout.split(tui, frame.area)

          # 左ペイン: レセプト一覧
          list_widget = Ui::ReceiptList.build(tui, @list_items, @state.selected_index)
          frame.render_widget(list_widget, areas[:left])

          # 右ペイン
          if @receipts.empty?
            draw_empty_detail(tui, frame, areas)
          else
            draw_detail(tui, frame, areas)
          end

          # ステータスバー
          draw_status_bar(tui, frame, areas[:status_bar])
        end
      end

      # @param tui [RatatuiRuby::Session]
      # @param frame [RatatuiRuby::Frame]
      # @param areas [Hash]
      def draw_detail(tui, frame, areas)
        receipt = @receipts[@state.selected_index]

        # ヘッダー
        header_data   = @presenter.header(receipt)
        header_widget = Ui::DetailView.build_header(tui, header_data)
        frame.render_widget(header_widget, areas[:right_header])

        # タブバー
        tab_bar_widget = Ui::DetailView.build_tab_bar(tui, @state.active_tab)
        frame.render_widget(tab_bar_widget, areas[:right_tab_bar])

        # タブコンテンツ
        draw_tab_content(tui, frame, areas[:right_content], receipt)
      end

      # @param tui [RatatuiRuby::Session]
      # @param frame [RatatuiRuby::Frame]
      # @param areas [Hash]
      def draw_empty_detail(tui, frame, areas)
        header_widget = Ui::DetailView.build_header(tui, nil)
        frame.render_widget(header_widget, areas[:right_header])

        tab_bar_widget = Ui::DetailView.build_tab_bar(tui, @state.active_tab)
        frame.render_widget(tab_bar_widget, areas[:right_tab_bar])

        empty = tui.paragraph(
          text:  'レセプトがありません',
          block: tui.block(borders: [:all])
        )
        frame.render_widget(empty, areas[:right_content])
      end

      # @param tui [RatatuiRuby::Session]
      # @param frame [RatatuiRuby::Frame]
      # @param area [RatatuiRuby::Rect]
      # @param receipt [Receipt]
      def draw_tab_content(tui, frame, area, receipt)
        widget = case @state.active_tab
                 when :tekiyou
                   tekiyou_lines = @presenter.tekiyou(receipt)
                   Ui::TekiyouTab.build(tui, tekiyou_lines, @state.tab_scroll_offset)
                 when :kaikei
                   kaikei_lines = @presenter.kaikei(receipt)
                   Ui::KaikeiTab.build(tui, kaikei_lines, @state.tab_scroll_offset)
                 end

        frame.render_widget(widget, area)
      end

      # @param tui [RatatuiRuby::Session]
      # @param frame [RatatuiRuby::Frame]
      # @param area [RatatuiRuby::Rect]
      def draw_status_bar(tui, frame, area)
        count_info = if @receipts.empty?
                       '0/0'
                     else
                       "#{@state.selected_index + 1}/#{@state.receipt_count}"
                     end

        status = tui.paragraph(
          text:  tui.text_line(
            spans: [
              tui.text_span(
                content: STATUS_TEXT,
                style:   tui.style(fg: :black, bg: :white)
              ),
              tui.text_span(
                content: " #{count_info} ",
                style:   tui.style(fg: :black, bg: :white, modifiers: [:bold])
              ),
            ]
          ),
          style: tui.style(bg: :white)
        )

        frame.render_widget(status, area)
      end

      # @param tui [RatatuiRuby::Session]
      # @return [Symbol, nil]
      def handle_event(tui)
        event = tui.poll_event
        KeyHandler.handle(event, @state)
      end
    end
  end
end
