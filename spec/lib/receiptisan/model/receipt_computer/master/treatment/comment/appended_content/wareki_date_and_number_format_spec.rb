# frozen_string_literal: true

require 'date'
require 'receiptisan'
require_relative 'appended_content_interface'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::AppendedContent::WarekiDateAndNumberFormat do
  before do
    stub_const('AppendedContent', Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::AppendedContent)
  end

  let(:wareki_date_format) { AppendedContent::WarekiDateFormat.new(_wareki = '５０４１２１３', _date = Date.new(2022, 12, 13)) }
  let(:number_format)      { AppendedContent::NumberFormat.new('０１５０') }
  let(:target)             { described_class.new(wareki_date_format, number_format) }

  describe 'behave as appended content' do
    it_behaves_like 'appended_content_interface'
  end

  describe '#to_s' do
    specify '和暦年月日と数値をまとめた文字列を返す' do
      expect(target.to_s).to eq '令和　４年１２月１３日０１５０'
    end
  end
end
