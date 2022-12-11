# frozen_string_literal: true

require 'receiptisan'
require_relative 'appended_content_interface'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::AppendedContent::FreeFormat do
  let(:value)  { 'フリーフォーマット' }
  let(:target) { described_class.new(value) }

  describe 'behave as appended content' do
    it_behaves_like 'appended_content_interface'
  end

  describe '#to_s' do
    specify 'valueをそのまま返す' do
      expect(target.to_s).to eq value
    end
  end
end
