# frozen_string_literal: true

require 'recediff'

# @param digit_length [Integer] 桁数
# @param name [String] 何のコードなのかを示すためのカテゴリ名称
RSpec.shared_examples Recediff::Model::ReceiptComputer::Master::MasterItemCodeInterface do | digit_length, name |
  describe '.of' do
    specify '文字列からインスタンスを生成できる' do
      expect(described_class.of(10**(digit_length - 1))).to be_instance_of(described_class)
    end

    specify '数値からインスタンスを生成できる' do
      expect(described_class.of(10**(digit_length - 1))).to be_instance_of(described_class)
    end

    specify '数値に解釈できないコードは例外を投げる' do
      expect { described_class.of('あいうえお') }.to raise_error(StandardError, /#{name}/)
    end

    specify '桁数が想定を超えるコードは例外を投げる' do
      expect { described_class.of(10**digit_length) }.to raise_error(StandardError, /#{name}/)
    end
  end

  let(:full_digits) { '123456789'[0, digit_length] }
  let(:zero_padded_digits) { ('%s1' % ['0' * (digit_length - 1)]) }

  describe '#value' do
    specify 'コードをシンボルで返す' do
      expect(described_class.of(full_digits).value).to eq full_digits.intern
    end

    specify '前ゼロを省略しても同じ桁数のコードになる(文字列より生成)' do
      expect(described_class.of('1').value).to eq zero_padded_digits.intern
    end

    specify '前ゼロを省略しても同じ桁数のコードになる(数値より生成)' do
      expect(described_class.of(1).value).to eq zero_padded_digits.intern
    end

    specify '前ゼロを省略しても同じ桁数のコードになる(シンボルより生成)' do
      expect(described_class.of(1).value).to eq zero_padded_digits.intern
    end
  end

  describe '#<=>' do
    context 'described_classと比較する場合' do
      specify 'コードが同じであれば、比較して真を返すこと' do
        expect(described_class.of(full_digits) == described_class.of(full_digits)).to be true
      end

      specify 'コードが異なれば、比較して偽を返すこと' do
        expect(described_class.of(full_digits) == described_class.of('9' * digit_length)).to be false
      end

      specify '数値として見れば同じコードであれば、桁数が違っても比較して真を返すこと' do
        expect(described_class.of(zero_padded_digits) == described_class.of('1')).to be true
      end
    end

    context '文字列と比較する場合' do
      specify 'コードが同じであれば、比較して真を返すこと' do
        expect(described_class.of(full_digits) == full_digits.to_s).to be true
      end

      specify 'コードが異なれば、比較して偽を返すこと' do
        expect(described_class.of(full_digits) == '9' * digit_length).to be false
      end

      specify '数値として見れば同じコードであれば、桁数が違っても比較して真を返すこと' do
        expect(described_class.of(zero_padded_digits) == '1').to be true
      end
    end

    context '数値と比較する場合' do
      specify 'コードが同じであれば、比較して真を返すこと' do
        expect(described_class.of(full_digits) == full_digits.to_i).to be true
      end

      specify 'コードが異なれば、比較して偽を返すこと' do
        expect(described_class.of(full_digits) == ('9' * digit_length).to_i).to be false
      end

      specify '数値として見れば同じコードであれば、桁数が違っても比較して真を返すこと' do
        expect(described_class.of(zero_padded_digits) == 1).to be true
      end
    end

    context 'シンボルと比較する場合' do
      specify 'コードが同じであれば、比較して真を返すこと' do
        expect(described_class.of(full_digits) == full_digits.intern).to be true
      end

      specify 'コードが異なれば、比較して偽を返すこと' do
        expect(described_class.of(full_digits) == ('9' * digit_length).to_i).to be false
      end

      specify '数値として見れば同じコードであれば、桁数が違っても比較して真を返すこと' do
        expect(described_class.of(zero_padded_digits) == :'1').to be true
      end
    end
  end
end
