# frozen_string_literal: true

require 'recediff'
require_relative '../../../../../shared/coded_item_with_short_name'

RSpec.describe Recediff::Model::ReceiptComputer::DigitalizedReceipt::Sex do
  context '男性' do
    it_behaves_like \
      'coded_item_with_short_name_examples',
      _target      = described_class.find_by_code(1),
      _target_name = '男性',
      _code        = 1,
      _code_type   = Integer,
      _name        = '男性',
      _short_name  = '男'
  end

  context '女性' do
    it_behaves_like \
      'coded_item_with_short_name_examples',
      _target      = described_class.find_by_code(2),
      _target_name = '女性',
      _code        = 2,
      _code_type   = Integer,
      _name        = '女性',
      _short_name  = '女'
  end
end
