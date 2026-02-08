# frozen_string_literal: true

require 'receiptisan'

Condition = Receiptisan::Model::ReceiptComputer::Master::Search::Condition

RSpec.describe Condition do
  describe '初期化' do
    context 'デフォルト値の場合' do
      let(:condition) { described_class.new }

      specify 'codeがnilであること' do
        expect(condition.code).to be_nil
      end

      specify 'nameがnilであること' do
        expect(condition.name).to be_nil
      end

      specify 'name_match_typeが:partialであること' do
        expect(condition.name_match_type).to eq :partial
      end

      specify 'point_minがnilであること' do
        expect(condition.point_min).to be_nil
      end

      specify 'point_maxがnilであること' do
        expect(condition.point_max).to be_nil
      end

      specify 'point_exactがnilであること' do
        expect(condition.point_exact).to be_nil
      end
    end

    context '全パラメータ指定の場合' do
      let(:condition) do
        described_class.new(
          code:            '111000110',
          name:            '初診',
          name_match_type: :exact,
          point_min:       100,
          point_max:       500,
          point_exact:     288
        )
      end

      specify 'codeが指定値であること' do
        expect(condition.code).to eq '111000110'
      end

      specify 'nameが指定値であること' do
        expect(condition.name).to eq '初診'
      end

      specify 'name_match_typeが:exactであること' do
        expect(condition.name_match_type).to eq :exact
      end

      specify 'point_minが指定値であること' do
        expect(condition.point_min).to eq 100
      end

      specify 'point_maxが指定値であること' do
        expect(condition.point_max).to eq 500
      end

      specify 'point_exactが指定値であること' do
        expect(condition.point_exact).to eq 288
      end
    end
  end
end
