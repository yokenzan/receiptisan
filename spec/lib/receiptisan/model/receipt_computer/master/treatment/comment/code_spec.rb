# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::Code do
  it_behaves_like Receiptisan::Model::ReceiptComputer::Master::MasterItemCodeInterface, _digit_lentgh = 9, _name = 'コメント'
end
