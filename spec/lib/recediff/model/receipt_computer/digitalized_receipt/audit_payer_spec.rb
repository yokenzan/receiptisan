# frozen_string_literal: true

require 'recediff'
require_relative '../../../../../shared/coded_item_with_short_name'

RSpec.describe Recediff::Model::ReceiptComputer::DigitalizedReceipt::AuditPayer do
  context '社保' do
    it_behaves_like \
      'coded_item_with_short_name_examples',
      described_class.find_by_code(described_class::PAYER_CODE_SHAHO),
      '社保',
      :'1',
      Symbol,
      '社会保険診療報酬支払基金',
      '社'
  end

  context '国保' do
    it_behaves_like \
      'coded_item_with_short_name_examples',
      described_class.find_by_code(described_class::PAYER_CODE_KOKUHO),
      '国保',
      :'2',
      Symbol,
      '国民健康保険団体連合会',
      '国'
  end
end
