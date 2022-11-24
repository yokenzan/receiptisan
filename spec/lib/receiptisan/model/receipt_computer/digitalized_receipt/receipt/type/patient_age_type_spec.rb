# frozen_string_literal: true

require 'receiptisan'
require_relative '../../../../../../../shared/coded_item'

RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Type::PatientAgeType do
  shared_examples 'patient age type examples' do | target, boolean_expected |
    describe '#nyuuin?' do
      specify '入院かどうか判定できる' do
        expect(target.nyuuin?).to be boolean_expected
      end
    end
  end

  context '本入' do
    it_behaves_like \
      'coded_item_examples',
      target = described_class.find_by_code(1),
      _target_name = '本入',
      _code        = 1,
      _code_type   = Integer,
      _name        = '本入'

    it_behaves_like 'patient age type examples', target, true
  end

  context '本外' do
    it_behaves_like \
      'coded_item_examples',
      target       = described_class.find_by_code(2),
      _target_name = '本外',
      _code        = 2,
      _code_type   = Integer,
      _name        = '本外'

    it_behaves_like 'patient age type examples', target, false
  end

  context '六入' do
    it_behaves_like \
      'coded_item_examples',
      target       = described_class.find_by_code(3),
      _target_name = '六入',
      _code        = 3,
      _code_type   = Integer,
      _name        = '六入'

    it_behaves_like 'patient age type examples', target, true
  end

  context '六外' do
    it_behaves_like \
      'coded_item_examples',
      target = described_class.find_by_code(4),
      _target_name = '六外',
      _code        = 4,
      _code_type   = Integer,
      _name        = '六外'

    it_behaves_like 'patient age type examples', target, false
  end

  context '家入' do
    it_behaves_like \
      'coded_item_examples',
      target       = described_class.find_by_code(5),
      _target_name = '家入',
      _code        = 5,
      _code_type   = Integer,
      _name        = '家入'

    it_behaves_like 'patient age type examples', target, true
  end

  context '家外' do
    it_behaves_like \
      'coded_item_examples',
      target = described_class.find_by_code(6),
      _target_name = '家外',
      _code        = 6,
      _code_type   = Integer,
      _name        = '家外'

    it_behaves_like 'patient age type examples', target, false
  end

  context '高入一' do
    it_behaves_like \
      'coded_item_examples',
      target       = described_class.find_by_code(7),
      _target_name = '高入一',
      _code        = 7,
      _code_type   = Integer,
      _name        = '高入一'

    it_behaves_like 'patient age type examples', target, true
  end

  context '高外一' do
    it_behaves_like \
      'coded_item_examples',
      target       = described_class.find_by_code(8),
      _target_name = '高外一',
      _code        = 8,
      _code_type   = Integer,
      _name        = '高外一'

    it_behaves_like 'patient age type examples', target, false
  end

  context '高入７' do
    it_behaves_like \
      'coded_item_examples',
      target       = described_class.find_by_code(9),
      _target_name = '高入７',
      _code        = 9,
      _code_type   = Integer,
      _name        = '高入７'

    it_behaves_like 'patient age type examples', target, true
  end

  context '高外７' do
    it_behaves_like \
      'coded_item_examples',
      target       = described_class.find_by_code(0),
      _target_name = '高外７',
      _code        = 0,
      _code_type   = Integer,
      _name        = '高外７'

    it_behaves_like 'patient age type examples', target, false
  end
end
