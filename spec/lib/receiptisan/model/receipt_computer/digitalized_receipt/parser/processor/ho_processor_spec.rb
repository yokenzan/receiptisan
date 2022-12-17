# frozen_string_literal: true

require 'month'
require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::Processor::HOProcessor do
  before do
    stub_const('DigitalizedReceipt', Receiptisan::Model::ReceiptComputer::DigitalizedReceipt)
    stub_const('IryouHoken',         DigitalizedReceipt::Receipt::IryouHoken)
    stub_const('TeishotokuType',     DigitalizedReceipt::Receipt::TeishotokuType)
  end

  let(:processor) { described_class.new }
  let(:target) do
    processor.process(
      <<~HO
        HO,  010108,記号記号記号記号記号,番号番号番号番号番号,31,46545,,93,61070,,,,,,
      HO
        .split(',')
        .map { | s | s.empty? ? nil : s },
      _kyuufu_wariai = 80,
      _tekiyou_type  = TeishotokuType.find_by_code(TeishotokuType::TYPE_TEISHOTOKU_1)
    )
  end

  describe '#process' do
    context '読込む行がHOレコードである場合' do
      specify '医療保険を返すこと' do
        expect(target).to be_instance_of IryouHoken
      end

      specify '保険者番号として"  010108"を返すこと' do # rubocop:disable RSpec/ExcessiveDocstringSpacing
        expect(target.hokenja_bangou).to eq '  010108'
      end

      specify '記号として"記号記号記号記号記号"を返すこと' do
        expect(target.kigou).to eq '記号記号記号記号記号'
      end

      specify '番号として"番号番号番号番号番号"を返すこと' do
        expect(target.bangou).to eq '番号番号番号番号番号'
      end

      specify '給付割合として8割(80)を返すこと' do
        expect(target.kyuufu_wariai).to eq 80
      end

      specify '低所得区分として低所得Ⅰを返すこと' do
        expect(target.teishotoku_type).to eq TeishotokuType.find_by_code(TeishotokuType::TYPE_TEISHOTOKU_1)
      end
    end

    context '読込む行がHOレコードでない場合' do
      specify '読込む行がREレコードだった場合、例外を投げること' do
        re_record = 'RE,2,1112,202110,カキクケコ,1,19910125,,,,,,,00698,,,,,,,,,,,,,,,,,,,,,,,カキクケコ,'
          .split(',')
          .map { | s | s.empty? ? nil : s }
        expect { processor.process(re_record) }.to raise_error(StandardError)
      end

      specify '読込む行がCOレコードだった場合、例外を投げること' do
        co_record = 'CO,70,2,820181220,'
          .split(',')
          .map { | s | s.empty? ? nil : s }
        expect { processor.process(co_record) }.to raise_error(StandardError)
      end

      specify '読込む行がSIレコードだった場合、例外を投げること' do
        si_record = 'SI,12,2,112015570,,50,1,,,,,,,1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'
          .split(',')
          .map { | s | s.empty? ? nil : s }
        expect { processor.process(si_record) }.to raise_error(StandardError)
      end
    end
  end
end
