# frozen_string_literal: true

require 'month'
require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::Processor::IRProcessor do
  before do
    stub_const('DigitalizedReceipt', Receiptisan::Model::ReceiptComputer::DigitalizedReceipt)
    stub_const('AuditPayer',         Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::AuditPayer)
  end

  let(:processor) { described_class.new }
  let(:target)    { processor.process('IR,2,01,1,9990000,,アイウエオ附属総合病院,202211,00,999-111-2222'.split(',').map { | s | s.empty? ? nil : s }, '東京都千代田区千代田１－１', 519) }

  describe '#process' do
    context '読込む行がIRレコードである場合' do
      specify '電子レセプトを返すこと' do
        expect(target).to be_instance_of DigitalizedReceipt
      end

      specify '請求年月が2022年11月であること' do
        expect(target.seikyuu_ym).to eq Month.new(2022, 11)
      end

      specify '審査支払機関が国保連であること' do
        expect(target.audit_payer).to eq AuditPayer.find_by_code(AuditPayer::PAYER_CODE_KOKUHO)
      end

      specify '医療機関を取得できること' do
        expect(target.hospital).to be_instance_of DigitalizedReceipt::Hospital
      end

      specify '医療機関の名称がアイウエオ附属総合病院であること' do
        expect(target.hospital.name).to eq 'アイウエオ附属総合病院'
      end

      specify '医療機関の都道府県が北海道であること' do
        expect(target.hospital.prefecture).to eq DigitalizedReceipt::Prefecture.find_by_code(1)
      end

      specify '医療機関の電話番号が999-111-2222であること' do
        expect(target.hospital.tel).to eq '999-111-2222'
      end

      specify '医療機関の医療機関コードが9990000であること' do
        expect(target.hospital.code).to eq '9990000'
      end

      specify '医療機関の所在地が東京都千代田区千代田１－１であること' do
        expect(target.hospital.location).to eq '東京都千代田区千代田１－１'
      end

      specify '医療機関の病床数が519床であること' do
        expect(target.hospital.bed_count).to eq 519
      end
    end

    context '読込む行がIRレコードでない場合' do
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
