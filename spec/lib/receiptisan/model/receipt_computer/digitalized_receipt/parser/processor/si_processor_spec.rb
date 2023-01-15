# frozen_string_literal: true

require 'month'
require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::Processor::SIProcessor do
  before do
    stub_const('DigitalizedReceipt',   Receiptisan::Model::ReceiptComputer::DigitalizedReceipt)
    stub_const('MasterShinryouKoui',   Receiptisan::Model::ReceiptComputer::Master::Treatment::ShinryouKoui)
    stub_const('ResourceShinryouKoui', DigitalizedReceipt::Receipt::Tekiyou::Resource::ShinryouKoui)
  end

  let(:shoshinryou) do
    MasterShinryouKoui.new(
      code:       :'111000110',
      name:       '初診料',
      name_kana:  'ショシンリョウ',
      unit:       nil,
      point_type: MasterShinryouKoui::PointType.find_by_code(3),
      point:      288,
      full_name:  '初診料'
    )
  end
  let(:context) { double(io_name: 'io_name', current_line_number: 999, current_line: 'current_line', current_receipt_id: 99) }
  let(:handler) do
    double('handler').as_null_object.tap do | dbl |
      allow(dbl).to receive(:find_by_code).with(MasterShinryouKoui::Code.of('111000110')).and_return(shoshinryou)
      allow(dbl).to receive(:find_by_code).with(MasterShinryouKoui::Code.of('999999999')).and_raise(Receiptisan::Model::ReceiptComputer::Master::MasterItemNotFoundError)
    end
  end

  describe '#process' do
    context '読込む行がSIレコードである場合' do
      let(:shoshin_processor) { described_class.new(logger: double(add: nil), context: context, handler: handler) }
      let(:resource_shoshin)  { shoshin_processor.process('SI,11,4,111000110,,288,1,,,,,,,,,,,,,,1,,,,,,,,,,,,,,,,,,,,,,,'.split(',').map { | s | s.empty? ? nil : s }) }

      specify '医療資源診療行為を返すこと' do
        expect(resource_shoshin).to be_instance_of ResourceShinryouKoui
      end

      specify '診療行為は初診料を返すこと' do
        expect(resource_shoshin.master_item).to eq shoshinryou
      end

      specify '使用量はnilを返すこと' do
        expect(resource_shoshin.shiyouryou).to be_nil
      end
    end

    context '読込む行がレセ電コードの存在しないSIレコードである場合' do
      let(:unknown_processor) { described_class.new(logger: double('logger', add: nil), context: context, handler: handler) }
      let(:resource_unknown)  { unknown_processor.process('SI,11,4,999999999,999,288,1,,,,,,,,,,,,,,1,,,,,,,,,,,,,,,,,,,,,,,'.split(',').map { | s | s.empty? ? nil : s }) }

      specify '医療資源診療行為を返すこと' do
        expect(resource_unknown).to be_instance_of ResourceShinryouKoui
      end

      specify '診療行為はダミーオブジェクトを返すこと' do
        expect(resource_unknown.master_item).to be_instance_of ResourceShinryouKoui::DummyMasterShinryouKoui
      end

      specify '使用量は999を返すこと' do
        expect(resource_unknown.shiyouryou).to eq 999
      end

      specify '存在しないレセ電コードだった場合、ログに書き出すこと' do
        spied_logger = spy('logger')

        described_class.new(logger: spied_logger, context: context, handler: handler).process('SI,11,4,999999999,999,288,1,,,,,,,,,,,,,,1,,,,,,,,,,,,,,,,,,,,,,,'.split(',').map { | s | s.empty? ? nil : s })

        expect(spied_logger).to have_received(:add).exactly(3).times
      end
    end

    context '読込む行がSIレコードでない場合' do
      let(:processor) { described_class.new(logger: double(add: nil), context: context, handler: handler) }

      specify '読込む行がREレコードだった場合、例外を投げること' do
        re_record = 'RE,2,1112,202110,カキクケコ,1,19910125,,,,,,,00698,,,,,,,,,,,,,,,,,,,,,,,カキクケコ,'
          .split(',')
          .map { | s | s.empty? ? nil : s }
        expect { processor.process(re_record) }.to raise_error(StandardError, 'line isnt SI record')
      end

      specify '読込む行がCOレコードだった場合、例外を投げること' do
        co_record = 'CO,70,2,820181220,'
          .split(',')
          .map { | s | s.empty? ? nil : s }
        expect { processor.process(co_record) }.to raise_error(StandardError, 'line isnt SI record')
      end
    end
  end
end
