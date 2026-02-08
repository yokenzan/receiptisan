# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::DailyKaisuu do
  describe '#on?' do
    let(:date) { Date.new(2024, 2, 1) }
    let(:daily_kaisuu) { described_class.new(date: date, kaisuu: 2) }

    specify '同じ日付ならtrueを返すこと' do
      expect(daily_kaisuu.on?(Date.new(2024, 2, 1))).to be true
    end

    specify '異なる日付ならfalseを返すこと' do
      expect(daily_kaisuu.on?(Date.new(2024, 2, 2))).to be false
    end
  end
end
