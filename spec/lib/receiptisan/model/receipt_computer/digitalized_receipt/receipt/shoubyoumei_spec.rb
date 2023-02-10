# frozen_string_literal: true

require 'receiptisan'
# require_relative '../../../../../../../shared/coded_item'

RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Shoubyoumei do
  let(:shoubyoumei) do
    described_class.new(
      master_shoubyoumei: Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shoubyoumei.new(
        code:      :'8836665',
        name:      '創傷感染症',
        name_kana: 'ソウショウカンセンショウ',
        full_name: '創傷感染症'
      ),
      worpro_name:        nil,
      is_main:            false,
      start_date:         Date.new(2022, 4, 1),
      tenki:              Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Shoubyoumei::Tenki::TENKI_継続,
      comment:            nil
    )
  end
  let(:prefix_migi) do
    Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo.new(
      code:      :'2056',
      name:      '右',
      name_kana: 'ミギ',
      category:  Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo::Category::CATEGORY_位置
    )
  end
  let(:prefix_shubu) do
    Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo.new(
      code:      :'1048',
      name:      '手部',
      name_kana: 'シュブ',
      category:  Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo::Category::CATEGORY_部位
    )
  end
  let(:suffix_jutsugo) do
    Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo.new(
      code:      :'8048',
      name:      'の術後',
      name_kana: 'ノジュツゴ',
      category:  Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo::Category::CATEGORY_接尾語
    )
  end
  let(:suffix_utagai) do
    Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo.new(
      code:      :'8002',
      name:      'の疑い',
      name_kana: 'ノウタガイ',
      category:  Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo::Category::CATEGORY_接尾語
    )
  end

  describe '#name' do
    context '傷病名のみの場合' do
      specify '傷病名の名称と一致すること' do
        target = shoubyoumei.dup

        expect(target.name).to eq '創傷感染症'
      end
    end

    context '傷病名と前置修飾語のみの場合' do
      specify '修飾語名 + 傷病名称に一致すること' do
        target = shoubyoumei.dup
        target.add_shuushokugo(prefix_migi)

        expect(target.name).to eq '右創傷感染症'
      end
    end

    context '傷病名と後置修飾語のみの場合' do
      specify '傷病名称 + 修飾語名に一致すること' do
        target = shoubyoumei.dup
        target.add_shuushokugo(suffix_jutsugo)

        expect(target.name).to eq '創傷感染症の術後'
      end
    end

    context '前置・後置修飾語のいずれもある場合' do
      specify '前置修飾語名 + 傷病名称 + 後置修飾語名に一致すること' do
        target = shoubyoumei.dup
        target.add_shuushokugo(prefix_migi)
        target.add_shuushokugo(suffix_jutsugo)

        expect(target.name).to eq '右創傷感染症の術後'
      end
    end

    context '前置修飾語が複数ある場合' do
      specify '修飾語間の順序が維持されること' do
        target = shoubyoumei.dup
        target.add_shuushokugo(prefix_migi)
        target.add_shuushokugo(prefix_shubu)

        expect(target.name).to eq '右手部創傷感染症'
      end
    end

    context '後置修飾語が複数ある場合' do
      specify '修飾語間の順序および前置・後置が維持されること' do
        target = shoubyoumei.dup
        target.add_shuushokugo(suffix_jutsugo)
        target.add_shuushokugo(suffix_utagai)

        expect(target.name).to eq '創傷感染症の術後の疑い'
      end
    end

    context '前置・後置修飾語のいずれも複数ある場合' do
      specify '修飾語間の順序および前置・後置が維持されること' do
        target = shoubyoumei.dup
        target.add_shuushokugo(prefix_migi)
        target.add_shuushokugo(prefix_shubu)
        target.add_shuushokugo(suffix_jutsugo)
        target.add_shuushokugo(suffix_utagai)

        expect(target.name).to eq '右手部創傷感染症の術後の疑い'
      end
    end
  end
end
