# frozen_string_literal: true

require 'recediff'

RSpec.describe Recediff::Model::ReceiptComputer::Master::Treatment::ShinryouKoui::Code do
  it_behaves_like Recediff::Model::ReceiptComputer::Master::MasterItemCodeInterface, _digit_lentgh = 9, _name = '診療行為'
end
