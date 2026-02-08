# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::CodeTypeResolver do
  describe '.resolve' do
    context '9桁コードの場合' do
      specify '先頭桁1で診療行為を返すこと' do
        expect(described_class.resolve('111000110')).to eq :shinryou_koui
      end

      specify '先頭桁6で医薬品を返すこと' do
        expect(described_class.resolve('610463016')).to eq :iyakuhin
      end

      specify '先頭桁7で特定器材を返すこと' do
        expect(described_class.resolve('700010000')).to eq :tokutei_kizai
      end

      specify '先頭桁8でコメントを返すこと' do
        expect(described_class.resolve('810000001')).to eq :comment
      end

      specify '判定できない先頭桁でArgumentErrorを発生すること' do
        expect { described_class.resolve('999999999') }
          .to raise_error(ArgumentError, /先頭桁/)
      end
    end

    context '7桁コードの場合' do
      specify '傷病名を返すこと' do
        expect(described_class.resolve('8830900')).to eq :shoubyoumei
      end
    end

    context '4桁コードの場合' do
      specify '修飾語を返すこと' do
        expect(described_class.resolve('2056')).to eq :shuushokugo
      end
    end

    context '不正な桁数の場合' do
      specify '5桁でArgumentErrorを発生すること' do
        expect { described_class.resolve('12345') }
          .to raise_error(ArgumentError, /種別を判定できません/)
      end

      specify '2桁でArgumentErrorを発生すること' do
        expect { described_class.resolve('12') }
          .to raise_error(ArgumentError, /種別を判定できません/)
      end
    end
  end
end
