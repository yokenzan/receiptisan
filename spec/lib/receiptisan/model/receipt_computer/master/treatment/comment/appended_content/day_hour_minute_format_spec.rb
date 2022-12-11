# frozen_string_literal: true

require 'receiptisan'
require_relative 'appended_content_interface'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::AppendedContent::DayHourMinuteFormat do
  let(:day)    { '０５' }
  let(:hour)   { '０６' }
  let(:minute) { '３８' }
  let(:target) { described_class.new(day, hour, minute) }

  describe 'behave as appended content' do
    it_behaves_like 'appended_content_interface'
  end

  describe '#to_s' do
    specify '値を日+時刻と見なして返す' do
      expect(target.to_s).to eq '０５日０６時３８分'
    end
  end
end
