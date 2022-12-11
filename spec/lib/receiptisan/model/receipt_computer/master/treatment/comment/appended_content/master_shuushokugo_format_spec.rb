# frozen_string_literal: true

require 'receiptisan'
require_relative 'appended_content_interface'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::AppendedContent::ShuushokugoFormat do
  before do
    stub_const('Master',    Receiptisan::Model::ReceiptComputer::Master)
    stub_const('Diagnosis', Receiptisan::Model::ReceiptComputer::Master::Diagnosis)
  end

  let(:master_shuushokugos) do
    [
      Diagnosis::Shuushokugo.new(
        code:      Diagnosis::Shuushokugo::Code.of('1298'),
        name:      '環指末節骨',
        name_kana: 'カンシマッセツコツ',
        category:  Diagnosis::Shuushokugo::Category.find_by_code(1)
      ),
      Diagnosis::Shuushokugo.new(
        code:      Diagnosis::Shuushokugo::Code.of('2060'),
        name:      '左右',
        name_kana: 'サユウ',
        category:  Diagnosis::Shuushokugo::Category.find_by_code(2)
      ),
      Diagnosis::Shuushokugo.new(
        code:      Diagnosis::Shuushokugo::Code.of('3088'),
        name:      '術後',
        name_kana: 'ジュツゴ',
        category:  Diagnosis::Shuushokugo::Category.find_by_code(3)
      ),
    ]
  end
  let(:target) { described_class.new(*master_shuushokugos) }

  describe 'behave as appended content' do
    it_behaves_like 'appended_content_interface'
  end

  describe '#to_s' do
    specify '修飾語名称を区切り文字なしで連結した文字列を返す' do
      expect(target.to_s).to eq '環指末節骨左右術後'
    end
  end
end
