# frozen_string_literal: true

require 'receiptisan'

MasterHandler = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::MasterHandler

RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::Processor::TOProcessor do
  before do
    stub_const('DigitalizedReceipt',   Receiptisan::Model::ReceiptComputer::DigitalizedReceipt)
    stub_const('Master',               Receiptisan::Model::ReceiptComputer::Master)
    stub_const('MasterTokuteiKizai',   Master::Treatment::TokuteiKizai)
    stub_const('TokuteiKizai',         DigitalizedReceipt::Receipt::Tekiyou::Resource::TokuteiKizai)
  end

  let(:master_tokutei_kizai) do
    MasterTokuteiKizai.new(
      code:       MasterTokuteiKizai::Code.of('770020070'),
      name:       '酸素',
      name_kana:  'サンソ',
      unit:       Master::Unit.find_by_code(49),
      price_type: MasterTokuteiKizai::PriceType.find_by_code(3),
      price:      0.19,
      full_name:  '酸素'
    )
  end
  let(:context) do
    instance_double(
      DigitalizedReceipt::Parser::Context,
      io_name: 'test.UKE', current_line_number: 10, current_line: 'TO,...', current_receipt_id: 1
    )
  end

  # TO行: TO,診療識別,負担区分,レセ電コード,使用量,点数,回数,単位コード,単価,...,商品名及び規格又はサイズ,...
  def build_to_values(code:, shiyouryou: nil, unit_code: '49', unit_price: nil, product_name: nil)
    values = Array.new(15)
    values[0]  = 'TO'
    values[3]  = code
    values[4]  = shiyouryou
    values[7]  = unit_code
    values[8]  = unit_price
    values[10] = product_name
    values
  end

  describe '#process' do
    context '読込む行がTOレコードである場合' do
      let(:handler) do
        instance_double(MasterHandler).tap do | dbl |
          allow(dbl).to receive(:find_by_code).with(MasterTokuteiKizai::Code.of('770020070')).and_return(master_tokutei_kizai)
        end
      end
      let(:processor) { described_class.new(logger: instance_double(Logger, add: nil), context: context, handler: handler) }

      specify '医療資源特定器材を返すこと' do
        result = processor.process(build_to_values(code: '770020070'))
        expect(result).to be_instance_of TokuteiKizai
      end
    end

    context 'レセ電コードがマスタに存在しない場合' do
      let(:handler) do
        instance_double(MasterHandler).tap do | dbl |
          allow(dbl).to receive(:find_by_code)
            .with(MasterTokuteiKizai::Code.of('999999999'))
            .and_raise(Master::MasterItemNotFoundError)
        end
      end
      let(:processor) { described_class.new(logger: instance_spy(Logger), context: context, handler: handler) }

      specify 'ダミーオブジェクトを含む特定器材を返すこと' do
        result = processor.process(build_to_values(code: '999999999'))
        expect(result.master_item).to be_instance_of TokuteiKizai::DummyMasterTokuteiKizai
      end

      specify 'report_error がログレベル Logger::WARN で呼ばれること' do
        spied_logger = instance_spy(Logger)
        proc_with_spy = described_class.new(logger: spied_logger, context: context, handler: handler)
        proc_with_spy.process(build_to_values(code: '999999999'))

        expect(spied_logger).to have_received(:add).with(Logger::WARN, anything).at_least(:once)
      end
    end

    context '読込む行がTOレコードでない場合' do
      let(:handler) { instance_double(MasterHandler) }
      let(:processor) { described_class.new(logger: instance_double(Logger, add: nil), context: context, handler: handler) }

      specify '例外を投げること' do
        expect { processor.process(%w[SI 11 4 999999999]) }.to raise_error(StandardError, 'line isnt TO record')
      end
    end
  end
end
