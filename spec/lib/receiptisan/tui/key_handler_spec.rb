# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Tui::KeyHandler do
  subject(:result) { described_class.handle(event, state) }

  let(:state) { Receiptisan::Tui::State.new(10) }

  describe 'quit' do
    context 'with q key' do
      let(:event) { { type: :key, code: 'q' } }

      it { is_expected.to eq :quit }
    end

    context 'with Ctrl-c' do
      let(:event) { { type: :key, code: 'c', modifiers: ['ctrl'] } }

      it { is_expected.to eq :quit }
    end
  end

  describe 'list navigation' do
    context 'with j key' do
      let(:event) { { type: :key, code: 'j' } }

      it 'moves selection down' do
        result
        expect(state.selected_index).to eq 1
      end
    end

    context 'with k key' do
      let(:event) { { type: :key, code: 'k' } }

      before { state.move_selection(3) }

      it 'moves selection up' do
        result
        expect(state.selected_index).to eq 2
      end
    end

    context 'with g key' do
      let(:event) { { type: :key, code: 'g' } }

      before { state.move_selection(5) }

      it 'moves to first' do
        result
        expect(state.selected_index).to eq 0
      end
    end

    context 'with G key' do
      let(:event) { { type: :key, code: 'G' } }

      it 'moves to last' do
        result
        expect(state.selected_index).to eq 9
      end
    end

    context 'with Ctrl-d' do
      let(:event) { { type: :key, code: 'd', modifiers: ['ctrl'] } }

      it 'moves selection by page size' do
        result
        expect(state.selected_index).to eq 9
      end
    end

    context 'with Ctrl-u' do
      let(:event) { { type: :key, code: 'u', modifiers: ['ctrl'] } }

      before { state.move_selection(9) }

      it 'moves selection up by page size' do
        result
        expect(state.selected_index).to eq 0
      end
    end
  end

  describe 'tab switching' do
    context 'with tab key' do
      let(:event) { { type: :key, code: 'tab' } }

      it 'toggles tab' do
        result
        expect(state.active_tab).to eq :kaikei
      end
    end
  end

  describe 'tab content scrolling' do
    context 'with J key' do
      let(:event) { { type: :key, code: 'J' } }

      it 'scrolls down' do
        result
        expect(state.tab_scroll_offset).to eq 1
      end
    end

    context 'with K key' do
      let(:event) { { type: :key, code: 'K' } }

      before { state.scroll_tab(3) }

      it 'scrolls up' do
        result
        expect(state.tab_scroll_offset).to eq 2
      end
    end

    context 'with Ctrl-f' do
      let(:event) { { type: :key, code: 'f', modifiers: ['ctrl'] } }

      it 'scrolls down by page' do
        result
        expect(state.tab_scroll_offset).to eq 10
      end
    end

    context 'with Ctrl-b' do
      let(:event) { { type: :key, code: 'b', modifiers: ['ctrl'] } }

      before { state.scroll_tab(15) }

      it 'scrolls up by page' do
        result
        expect(state.tab_scroll_offset).to eq 5
      end
    end
  end

  describe 'non-key events' do
    let(:event) { { type: :resize } }

    it { is_expected.to be_nil }
  end
end
