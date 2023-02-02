# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Util::Formatter do
  # TODO: Integer以外のパターン

  describe '#to_currency' do
    context 'nil' do
        specify '空文字列を返すこと' do
          expect(described_class.to_currency(nil)).to eq ''
        end
    end

    context '正の整数' do
      context '4桁のとき' do
        specify '千の位と百の位の間にカンマを付した文字列を返すこと' do
          expect(described_class.to_currency(1234)).to eq '1,234'
        end
      end

      context '6桁のとき' do
        specify '千の位と百の位の間にカンマを付した文字列を返すこと' do
          expect(described_class.to_currency(123_456)).to eq '123,456'
        end
      end

      context '7桁のとき' do
        specify '百万の位と十万の位、千の位と百の位の間にそれぞれカンマを付した文字列を返すこと' do
          expect(described_class.to_currency(1_234_567)).to eq '1,234,567'
        end
      end

      context '3桁のとき' do
        specify 'カンマを付さず3桁の数値を文字列として返すこと' do
          expect(described_class.to_currency(123)).to eq '123'
        end
      end
    end

    context '負の整数' do
      context '4桁のとき' do
        specify 'マイナス符号つきの、千の位と百の位の間にカンマを付した文字列を返すこと' do
          expect(described_class.to_currency(-1234)).to eq '-1,234'
        end
      end

      context '3桁のとき' do
        specify 'カンマを付さず3桁の数値を文字列として返すこと' do
          expect(described_class.to_currency(-123)).to eq '-123'
        end
      end
    end
  end
end
