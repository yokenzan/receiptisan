# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Treatment::Iyakuhin::Code do
  it_behaves_like Receiptisan::Model::ReceiptComputer::Master::MasterItemCodeInterface, _digit_lentgh = 9, _name = '医薬品'
end
