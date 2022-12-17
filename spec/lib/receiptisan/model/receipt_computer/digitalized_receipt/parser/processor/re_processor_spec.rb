# frozen_string_literal: true

require 'month'
require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::Processor::REProcessor do
  before do
    stub_const('DigitalizedReceipt', Receiptisan::Model::ReceiptComputer::DigitalizedReceipt)
    stub_const('Receipt',            DigitalizedReceipt::Receipt)
  end

  let(:processor)   { described_class.new }
  let(:audit_payer) { DigitalizedReceipt::AuditPayer.find_by_code(DigitalizedReceipt::AuditPayer::PAYER_CODE_KOKUHO) }
  let(:target) do
    processor.process(
      <<~RE
        RE,80,1347,202207,グレートブリテン及北アイルランド連合王国,2,19911121,,20190913,07,,0929,,7368,,,,,,,,,,,,,,,,,,,,,,,グレートブリテンオヨビキタアイルランドレンゴウオウコク,
      RE
        .split(',')
        .map { | s | s.empty? ? nil : s },
      audit_payer
    )
  end

  describe '#process' do
    context '読込む行がREレコードである場合' do
      specify 'レセプトを返すこと' do
        expect(target).to be_instance_of Receipt
      end

      specify 'IDが80であること' do
        expect(target.id).to eq 80
      end

      specify '診療年月が2022年7月であること' do
        expect(target.shinryou_ym).to eq Month.new(2022, 7)
      end

      specify 'レセプト種別を取得できること' do
        expect(target.type).to be_instance_of Receipt::Type
      end

      specify '点数表種別が医科であること' do
        expect(target.type.tensuu_hyou_type).to eq Receipt::Type::TensuuHyouType.find_by_code(Receipt::Type::TensuuHyouType::TYPE_IKA)
      end

      specify '主保険種別が後期であること' do # rubocop:disable RSpec/MultipleExpectations
        expect(target.type.main_hoken_type.code).to eq 3
        expect(target.type.main_hoken_type.name).to eq '後期'
      end

      specify '保険併用種別が４併であること' do
        expect(target.type.hoken_multiple_type).to eq Receipt::Type::HokenMultipleType.find_by_code(Receipt::Type::HokenMultipleType::TYPE_4_HEIYOU)
      end

      specify '特記事項を2つもっていること' do
        expect(target.tokki_jikous.length).to eq 2
      end

      specify '09施の特記事項をもっていること' do
        expect(target.tokki_jikous).to include('09' => Receipt::TokkiJikou.find_by_code('09'))
      end

      specify '29区エの特記事項をもっていること' do
        expect(target.tokki_jikous).to include('29' => Receipt::TokkiJikou.find_by_code('29'))
      end

      specify '患者年齢種別が高入一であること' do
        expect(target.type.patient_age_type).to eq Receipt::Type::PatientAgeType.find_by_code(7)
      end

      specify '病床区分として療養病棟だけであること' do
        expect(target.byoushou_types).to contain_exactly(DigitalizedReceipt::ByoushouType.find_by_code(DigitalizedReceipt::ByoushouType::BYOUSHOU_TYPE_RYOUYOU))
      end

      specify '患者を取得できること' do
        expect(target.patient).to be_instance_of Receipt::Patient
      end

      specify '患者カルテ番号が7368の文字列であること' do
        expect(target.patient.id).to eq '7368'
      end

      specify '患者氏名が『グレートブリテン及北アイルランド連合王国』であること' do
        expect(target.patient.name).to eq 'グレートブリテン及北アイルランド連合王国'
      end

      specify '患者カナ氏名が『グレートブリテンオヨビキタアイルランドレンゴウオウコク』であること' do
        expect(target.patient.name_kana).to eq 'グレートブリテンオヨビキタアイルランドレンゴウオウコク'
      end

      specify '患者性別が女性であること' do
        expect(target.patient.sex).to eq DigitalizedReceipt::Sex.find_by_code(DigitalizedReceipt::Sex::SEX_FEMALE)
      end

      specify '患者生年月日が1991年11月21日であること' do
        expect(target.patient.birth_date).to eq Date.new(1991, 11, 21)
      end

      specify 'processorは読み込んだ低所得区分としてnilを返すこと' do
        expect(processor.teishotoku_type).to be_nil
      end

      specify '読み込んだ給付割合としてnilを返すこと' do
        expect(processor.kyuufu_wariai).to be_nil
      end
    end

    context '読込む行がREレコードでない場合' do
      specify '読込む行がIRレコードだった場合、例外を投げること' do
        ir_record = 'IR,2,01,1,9990000,,アイウエオ附属総合病院,202211,00,999-111-2222'
          .split(',')
          .map { | s | s.empty? ? nil : s }
        expect { processor.process(ir_record, audit_payer) }.to raise_error(StandardError)
      end

      specify '読込む行がCOレコードだった場合、例外を投げること' do
        co_record = 'CO,70,2,820181220,'
          .split(',')
          .map { | s | s.empty? ? nil : s }
        expect { processor.process(co_record, audit_payer) }.to raise_error(StandardError)
      end

      specify '読込む行がSIレコードだった場合、例外を投げること' do
        si_record = 'SI,12,2,112015570,,50,1,,,,,,,1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'
          .split(',')
          .map { | s | s.empty? ? nil : s }
        expect { processor.process(si_record, audit_payer) }.to raise_error(StandardError)
      end
    end
  end
end
