# frozen_string_literal: true

require 'recediff'

RSpec.describe Recediff::Model::ReceiptComputer::Master::Treatment::TokuteiKizai::Code do
  it_behaves_like Recediff::Model::ReceiptComputer::Master::MasterItemCodeInterface, _digit_lentgh = 9, _name = '特定器材'
end
