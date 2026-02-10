# frozen_string_literal: true

require 'date'
require 'receiptisan'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::Processor::SYProcessor do
  before do
    stub_const('DigitalizedReceipt',   Receiptisan::Model::ReceiptComputer::DigitalizedReceipt)
    stub_const('Master',               Receiptisan::Model::ReceiptComputer::Master)
    stub_const('MasterShoubyoumei',    Master::Diagnosis::Shoubyoumei)
    stub_const('MasterShuushokugo',    Master::Diagnosis::Shuushokugo)
    stub_const('Shoubyoumei',          DigitalizedReceipt::Receipt::Shoubyoumei)
  end

  let(:master_shoubyoumei) do
    MasterShoubyoumei.new(
      code:      MasterShoubyoumei::Code.of('8830100'),
      full_name: '糖尿病',
      name:      '糖尿病',
      name_kana: 'トウニョウビョウ'
    )
  end
  let(:master_shuushokugo) do
    MasterShuushokugo.new(
      code:      MasterShuushokugo::Code.of('8002'),
      name:      '急性',
      name_kana: 'キュウセイ',
      category:  MasterShuushokugo::Category::CATEGORY_経過表現
    )
  end
  let(:context) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::Context,
      io_name: 'test.UKE', current_line_number: 10, current_line: 'SY,...', current_receipt_id: 1
    )
  end
  let(:logger) { instance_double(Logger, add: nil) }

  # SY行: SY,傷病名コード,診療開始日,転帰区分,修飾語コード,傷病名称,主傷病,補足コメント
  def build_sy_values(shoubyoumei_code:, start_date: '20210401', tenki: '1', shuushokugo_codes: nil, name: nil, main: nil, comment: nil)
    ['SY', shoubyoumei_code, start_date, tenki, shuushokugo_codes, name, main, comment]
  end

  describe '#process' do
    context '修飾語コードが存在しないSYレコードの場合' do
      let(:handler) do
        instance_double(Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::MasterHandler).tap do | dbl |
          allow(dbl).to receive(:find_by_code).with(MasterShoubyoumei::Code.of('8830100')).and_return(master_shoubyoumei)
        end
      end
      let(:processor) { described_class.new(logger: logger, context: context, handler: handler) }

      specify '傷病名を返すこと' do
        result = processor.process(build_sy_values(shoubyoumei_code: '8830100'))
        expect(result).to be_instance_of Shoubyoumei
      end
    end

    context '修飾語コードが存在するSYレコードの場合' do
      let(:handler) do
        instance_double(Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::MasterHandler).tap do | dbl |
          allow(dbl).to receive(:find_by_code).with(an_instance_of(MasterShoubyoumei::Code)).and_return(master_shoubyoumei)
          allow(dbl).to receive(:find_by_code).with(an_instance_of(MasterShuushokugo::Code)).and_return(master_shuushokugo)
        end
      end
      let(:processor) { described_class.new(logger: logger, context: context, handler: handler) }

      specify '修飾語が傷病名に追加されていること' do
        result = processor.process(build_sy_values(shoubyoumei_code: '8830100', shuushokugo_codes: '8002'))
        expect(result.master_shuushokugos).to contain_exactly(master_shuushokugo)
      end
    end

    context 'マスタに傷病名コードが存在しないSYレコードの場合' do
      let(:handler) do
        instance_double(Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::MasterHandler).tap do | dbl |
          allow(dbl).to receive(:find_by_code)
            .with(MasterShoubyoumei::Code.of('9999999'))
            .and_raise(Master::MasterItemNotFoundError)
        end
      end
      let(:processor) { described_class.new(logger: logger, context: context, handler: handler) }

      specify 'ダミーオブジェクトを含む傷病名を返すこと' do
        result = processor.process(build_sy_values(shoubyoumei_code: '9999999'))
        expect(result.master_shoubyoumei).to be_instance_of Shoubyoumei::DummyMasterShoubyoumei
      end
    end

    context 'マスタに修飾語コードが存在しないSYレコードの場合' do
      let(:handler) do
        instance_double(Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::MasterHandler).tap do | dbl |
          allow(dbl).to receive(:find_by_code).with(an_instance_of(MasterShoubyoumei::Code)).and_return(master_shoubyoumei)
          allow(dbl).to receive(:find_by_code)
            .with(an_instance_of(MasterShuushokugo::Code))
            .and_raise(Master::MasterItemNotFoundError)
        end
      end
      let(:processor) { described_class.new(logger: logger, context: context, handler: handler) }

      specify 'ダミー修飾語が傷病名に追加されていること' do
        result = processor.process(build_sy_values(shoubyoumei_code: '8830100', shuushokugo_codes: '9999'))
        expect(result.master_shuushokugos.first).to be_instance_of Shoubyoumei::DummyMasterShuushokugo
      end

      specify 'ダミー修飾語のコードが正しいこと' do
        result = processor.process(build_sy_values(shoubyoumei_code: '8830100', shuushokugo_codes: '9999'))
        expect(result.master_shuushokugos.first.code).to eq MasterShuushokugo::Code.of('9999')
      end
    end

    context '読込む行がSYレコードでない場合' do
      let(:handler) { instance_double(Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::MasterHandler) }
      let(:processor) { described_class.new(logger: logger, context: context, handler: handler) }

      specify '例外を投げること' do
        expect { processor.process(%w[RE 2 1112]) }.to raise_error(StandardError, 'line isnt SY record')
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
