# frozen_string_literal: true

require 'receiptisan'
require_relative 'appended_content_interface'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::AppendedContent::MinuteFormat do
  let(:minute) { '０８' }
  let(:target) { described_class.new(minute) }

  describe 'behave as appended content' do
    it_behaves_like 'appended_content_interface'
  end

  describe '#to_s' do
    specify '値を分と見なして返す' do
      expect(target.to_s).to eq '０８分'
    end
  end
end
