# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::IchirenUnit do
  def resource
    Struct.new(:type, :name, :code, keyword_init: true).new(type: :shinryou_koui, name: 'test', code: '000000')
  end

  def shinryou_shikibetsu
    Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu.find_by_code('11')
  end

  def futan_kubun
    Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::FutanKubun.find_by_code('1')
  end

  def build_daily_kaisuu(date:, kaisuu:)
    Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::DailyKaisuu.new(date: date, kaisuu: kaisuu)
  end

  def build_cost(daily_kaisuu_items:)
    Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::Cost.new(
      resource:            resource,
      shinryou_shikibetsu: shinryou_shikibetsu,
      futan_kubun:         futan_kubun,
      tensuu:              100,
      kaisuu:              1,
      daily_kaisuus:       daily_kaisuu_items
    )
  end

  def build_santei_unit(daily_kaisuu_items:)
    Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit.new.tap do | unit |
      unit.add_tekiyou(build_cost(daily_kaisuu_items: daily_kaisuu_items))
      unit.fix!
    end
  end

  describe '#on_date' do
    specify '該当日がある算定単位のみを返すこと' do
      date_one = Date.new(2024, 2, 1)
      date_two = Date.new(2024, 2, 2)
      daily_kaisuu_one = build_daily_kaisuu(date: date_one, kaisuu: 1)
      daily_kaisuu_two = build_daily_kaisuu(date: date_two, kaisuu: 2)

      ichiren_unit = described_class.new(shinryou_shikibetsu: shinryou_shikibetsu)
      ichiren_unit.add_santei_unit(build_santei_unit(daily_kaisuu_items: [daily_kaisuu_one]))
      ichiren_unit.add_santei_unit(build_santei_unit(daily_kaisuu_items: [daily_kaisuu_two]))

      filtered = ichiren_unit.on_date(date_one)

      expect(filtered.map { | unit | unit.each_date.to_a }).to eq [[daily_kaisuu_one]]
    end

    specify '該当日がない場合はnilを返すこと' do
      date_one = Date.new(2024, 2, 1)
      date_other = Date.new(2024, 2, 3)
      daily_kaisuu_one = build_daily_kaisuu(date: date_one, kaisuu: 1)

      ichiren_unit = described_class.new(shinryou_shikibetsu: shinryou_shikibetsu)
      ichiren_unit.add_santei_unit(build_santei_unit(daily_kaisuu_items: [daily_kaisuu_one]))

      expect(ichiren_unit.on_date(date_other)).to be_nil
    end
  end
end
