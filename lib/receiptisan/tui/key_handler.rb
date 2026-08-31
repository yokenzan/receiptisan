# frozen_string_literal: true

module Receiptisan
  module Tui
    # キーボードイベントを状態変更にマッピング
    module KeyHandler
      PAGE_SIZE = 10

      module_function

      # @param event [RatatuiRuby::Event] RatatuiRuby のイベント
      # @param state [State]
      # @return [Symbol, nil] :quit を返すと終了
      def handle(event, state)
        case event
        in type: :key, code: String => code, modifiers: Array => modifiers
          handle_key(code, modifiers, state)
        in type: :key, code: String => code
          handle_key(code, [], state)
        else
          nil
        end
      end

      # @param code [String]
      # @param modifiers [Array]
      # @param state [State]
      # @return [Symbol, nil]
      def handle_key(code, modifiers, state)
        ctrl = modifiers.any? { | m | m.match?(/ctrl/i) }

        ctrl ? handle_ctrl_key(code, state) : handle_plain_key(code, state)
      end

      # @param code [String]
      # @param state [State]
      # @return [Symbol, nil]
      def handle_plain_key(code, state) # rubocop:disable Metrics/CyclomaticComplexity
        case code
        when 'q'         then :quit
        when 'j', 'down' then state.move_selection(1)
        when 'k', 'up'   then state.move_selection(-1)
        when 'g'         then state.select_first
        when 'G', 'end'  then state.select_last
        when 'tab'       then state.toggle_tab
        when 'J'         then state.scroll_tab(1)
        when 'K'         then state.scroll_tab(-1)
        end
      end

      # @param code [String]
      # @param state [State]
      # @return [Symbol, nil]
      def handle_ctrl_key(code, state)
        case code
        when 'c'      then :quit
        when 'd'      then state.move_selection(PAGE_SIZE)
        when 'u'      then state.move_selection(-PAGE_SIZE)
        when 'e'      then state.scroll_tab(1)
        when 'y'      then state.scroll_tab(-1)
        when 'f'      then state.scroll_tab(PAGE_SIZE)
        when 'b'      then state.scroll_tab(-PAGE_SIZE)
        end
      end

      private_class_method :handle_key, :handle_plain_key, :handle_ctrl_key
    end
  end
end
