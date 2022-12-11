# frozen_string_literal: true

require 'date'
require 'receiptisan'
require_relative 'appended_content_interface'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::AppendedContent::WarekiDateFormat do
  let(:date)   { Date.new(2022, 12, 13) }
  let(:target) { described_class.new(_wareki = '５０４１２１３', date) }

  describe 'behave as appended content' do
    it_behaves_like 'appended_content_interface'
  end

  describe '#to_s' do
    specify '全角文字を使った和暦年月日を返す' do
      expect(target.to_s).to eq '令和　４年１２月１３日'
    end
  end
end
