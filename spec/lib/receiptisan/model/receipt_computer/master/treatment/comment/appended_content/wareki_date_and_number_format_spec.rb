# frozen_string_literal: true

require 'rspec'
require 'date'
require 'receiptisan'
require_relative 'appended_content_interface'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::AppendedContent::WarekiDateAndNumberFormat do
  before do
    stub_const('AppendedContent', Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::AppendedContent)
  end

  let(:wareki_to_date)     { Date.new(2022, 12, 13) }
  let(:wareki_date_format) { AppendedContent::WarekiDateFormat.new(_wareki = '５０４１２１３', _date = wareki_to_date) }
  let(:number_format) { AppendedContent::NumberFormat.new('００００００．７') }
  let(:target) { described_class.new(wareki_date_format, wareki_to_date, number_format) }

  describe 'behave as appended content' do
    it_behaves_like 'appended_content_interface'
  end

  describe '#to_s' do
    specify '和暦年月日と数値をまとめた文字列を返す' do
      expect(target.to_s).to eq '令和　４年１２月１３日　検査値：０．７'
    end

    context '検査値' do
      specify '０が除かれた整数値が返ること' do
        number_format = AppendedContent::NumberFormat.new('０００００１２３')
        target = described_class.new(wareki_date_format, wareki_to_date, number_format)

        expect(target.to_s).to eq '令和　４年１２月１３日　検査値：１２３'
      end

      specify '０が除かれた小数値が返ること' do
        number_format = AppendedContent::NumberFormat.new('０００１２３．４５')
        target = described_class.new(wareki_date_format, wareki_to_date, number_format)

        expect(target.to_s).to eq '令和　４年１２月１３日　検査値：１２３．４５'
      end

      specify '０が返ること' do
        number_format = AppendedContent::NumberFormat.new('００００００００')
        target = described_class.new(wareki_date_format, wareki_to_date, number_format)

        expect(target.to_s).to eq '令和　４年１２月１３日　検査値：０'
      end

      specify '０埋めがない場合、整数値が返ること' do
        number_format = AppendedContent::NumberFormat.new('１０００００００')
        target = described_class.new(wareki_date_format, wareki_to_date, number_format)

        expect(target.to_s).to eq '令和　４年１２月１３日　検査値：１０００００００'
      end
    end
  end
end
