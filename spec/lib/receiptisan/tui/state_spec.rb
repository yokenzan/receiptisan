# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Tui::State do
  subject(:state) { described_class.new(receipt_count) }

  let(:receipt_count) { 10 }

  describe '#initialize' do
    it 'starts with default values', :aggregate_failures do
      expect(state.selected_index).to eq 0
      expect(state.active_tab).to eq :tekiyou
      expect(state.tab_scroll_offset).to eq 0
      expect(state.receipt_count).to eq 10
    end
  end

  describe '#move_selection' do
    it 'moves selection down' do
      state.move_selection(1)
      expect(state.selected_index).to eq 1
    end

    it 'moves selection up' do
      state.move_selection(3)
      state.move_selection(-1)
      expect(state.selected_index).to eq 2
    end

    it 'clamps to valid range', :aggregate_failures do
      state.move_selection(100)
      expect(state.selected_index).to eq 9

      state.move_selection(-100)
      expect(state.selected_index).to eq 0
    end

    it 'resets tab scroll offset on selection change' do
      state.scroll_tab(5)
      state.move_selection(1)
      expect(state.tab_scroll_offset).to eq 0
    end

    context 'with zero receipts' do
      let(:receipt_count) { 0 }

      it 'does not move' do
        state.move_selection(1)
        expect(state.selected_index).to eq 0
      end
    end
  end

  describe '#select_first' do
    it 'moves to first receipt' do
      state.move_selection(5)
      state.select_first
      expect(state.selected_index).to eq 0
    end

    it 'resets tab scroll offset' do
      state.move_selection(5)
      state.scroll_tab(3)
      state.select_first
      expect(state.tab_scroll_offset).to eq 0
    end
  end

  describe '#select_last' do
    it 'moves to last receipt' do
      state.select_last
      expect(state.selected_index).to eq 9
    end

    context 'with zero receipts' do
      let(:receipt_count) { 0 }

      it 'does not move' do
        state.select_last
        expect(state.selected_index).to eq 0
      end
    end
  end

  describe '#toggle_tab' do
    it 'switches between tekiyou and kaikei', :aggregate_failures do
      expect(state.active_tab).to eq :tekiyou
      state.toggle_tab
      expect(state.active_tab).to eq :kaikei
      state.toggle_tab
      expect(state.active_tab).to eq :tekiyou
    end

    it 'resets tab scroll offset' do
      state.scroll_tab(5)
      state.toggle_tab
      expect(state.tab_scroll_offset).to eq 0
    end
  end

  describe '#scroll_tab' do
    it 'scrolls down' do
      state.scroll_tab(3)
      expect(state.tab_scroll_offset).to eq 3
    end

    it 'does not scroll below zero' do
      state.scroll_tab(-5)
      expect(state.tab_scroll_offset).to eq 0
    end

    it 'accumulates scroll offset' do
      state.scroll_tab(2)
      state.scroll_tab(3)
      expect(state.tab_scroll_offset).to eq 5
    end
  end
end
