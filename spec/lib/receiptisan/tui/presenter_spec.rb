# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Tui::Presenter do
  subject(:presenter) { described_class.new }

  let(:receipt) do
    rc = Receiptisan::Model::ReceiptComputer

    sex = rc::DigitalizedReceipt::Sex.find_by_code(1)
    patient = rc::DigitalizedReceipt::Receipt::Patient.new(
      id:         '12345',
      name:       '山田太郎',
      name_kana:  'ヤマダタロウ',
      sex:        sex,
      birth_date: Date.new(1985, 1, 1)
    )

    tensuu_hyou  = rc::DigitalizedReceipt::Receipt::Type::TensuuHyouType.find_by_code(1)
    main_hoken   = rc::DigitalizedReceipt::Receipt::Type::MainHokenType.new(code: 1, name: '社国')
    hoken_multi  = rc::DigitalizedReceipt::Receipt::Type::HokenMultipleType.find_by_code(1)
    patient_age  = rc::DigitalizedReceipt::Receipt::Type::PatientAgeType.find_by_code(2)
    receipt_type = rc::DigitalizedReceipt::Receipt::Type.new(tensuu_hyou, main_hoken, hoken_multi, patient_age)

    rc::DigitalizedReceipt::Receipt.new(
      id:          1,
      shinryou_ym: Month.new(2024, 6),
      patient:     patient,
      type:        receipt_type,
      nyuuin_date: nil,
      audit_payer: nil
    )
  end

  describe '#list_items' do
    it 'generates list items from receipts', :aggregate_failures do
      items = presenter.list_items([receipt])

      expect(items.length).to eq 1
      expect(items.first.label).to include('No.0001')
      expect(items.first.label).to include('外来')
      expect(items.first.label).to include('山田太郎')
    end

    it 'numbers receipts sequentially', :aggregate_failures do
      items = presenter.list_items([receipt, receipt])
      expect(items[0].label).to include('No.0001')
      expect(items[1].label).to include('No.0002')
    end
  end

  describe '#header' do
    it 'generates header data', :aggregate_failures do
      header = presenter.header(receipt)

      expect(header.patient_line).to include('12345')
      expect(header.patient_line).to include('山田太郎')
      expect(header.patient_line).to include('男')
      expect(header.type_line).to include('外来')
      expect(header.nyuuin_line).to be_nil
    end

    it 'shows tokki when present' do
      rc = Receiptisan::Model::ReceiptComputer
      tokki = rc::DigitalizedReceipt::Receipt::TokkiJikou.find_by_code('01')
      receipt.add_tokki_jikou(tokki)

      header = presenter.header(receipt)
      expect(header.tokki_line).to include('公')
    end
  end

  describe '#tekiyou' do
    it 'returns empty array for receipt without tekiyou' do
      lines = presenter.tekiyou(receipt)
      expect(lines).to be_empty
    end
  end

  describe '#kaikei' do
    it 'returns an array' do
      lines = presenter.kaikei(receipt)
      expect(lines).to be_an(Array)
    end

    it 'includes tokki section when present', :aggregate_failures do
      rc = Receiptisan::Model::ReceiptComputer
      tokki = rc::DigitalizedReceipt::Receipt::TokkiJikou.find_by_code('01')
      receipt.add_tokki_jikou(tokki)

      lines = presenter.kaikei(receipt)
      labels = lines.map(&:label)
      expect(labels).to include('== 特記事項 ==')
      expect(labels).to include('01 公')
    end
  end
end
