# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Util::Formatter::KakkotsukiFormatter do
  describe '#convert' do
    context '0を渡したとき' do
      specify '⑴を返す' do
        expect(described_class.convert(0)).to eq '⑴'
      end
    end

    context '1を渡したとき' do
      specify '⑵を返す' do
        expect(described_class.convert(1)).to eq '⑵'
      end
    end

    context '3を渡したとき' do
      specify '⑶を返す' do
        expect(described_class.convert(2)).to eq '⑶'
      end
    end

    context '19を渡したとき' do
      specify '⒇を返す' do
        expect(described_class.convert(19)).to eq '⒇'
      end
    end

    context '20を渡したとき' do
      specify '(21)は表示不可能なので範囲外である旨例外を投げる' do
        expect { described_class.convert(20) }.to raise_error(ArgumentError, "given index is out of range (0~19): '20'")
      end
    end
  end

  describe '#format' do
    context 'カッコ数字を含む文字列を渡したとき' do
      context '「生化学的検査（１）判断料」を渡したとき' do
        specify '「生化学的検査⑴判断料」を返す' do
          expect(described_class.format('生化学的検査（１）判断料')).to eq '生化学的検査⑴判断料'
        end
      end

      context '「生化学的検査（２）判断料」を渡したとき' do
        specify '「生化学的検査⑵判断料」を返す' do
          expect(described_class.format('生化学的検査（２）判断料')).to eq '生化学的検査⑵判断料'
        end
      end
    end

    context('カッコ数字を含まない文字列を渡したとき') do
      context '「処方箋料（リフィル以外・その他）」を渡したとき' do
        specify '何も変更せず「処方箋料（リフィル以外・その他）」を返す' do
          expect(described_class.format('処方箋料（リフィル以外・その他）')).to eq '処方箋料（リフィル以外・その他）'
        end
      end

      context '「一般名処方加算２（処方箋料）」を渡したとき' do
        specify '何も変更せず「一般名処方加算２（処方箋料）」を返す' do
          expect(described_class.format('一般名処方加算２（処方箋料）')).to eq '一般名処方加算２（処方箋料）'
        end
      end
    end
  end
end
