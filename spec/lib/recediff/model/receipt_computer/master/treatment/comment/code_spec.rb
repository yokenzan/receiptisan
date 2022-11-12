# frozen_string_literal: true

require 'recediff'

RSpec.describe Recediff::Model::ReceiptComputer::Master::Treatment::Comment::Code do
  it_behaves_like Recediff::Model::ReceiptComputer::Master::MasterItemCodeInterface, _digit_lentgh = 9, _name = 'コメント'
end
