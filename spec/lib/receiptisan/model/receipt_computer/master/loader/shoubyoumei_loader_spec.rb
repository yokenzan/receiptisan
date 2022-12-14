# frozen_string_literal: true

require 'pathname'
require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Loader::ShoubyoumeiLoader do
  Version     = Receiptisan::Model::ReceiptComputer::Master::Version
  Shoubyoumei = Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shoubyoumei
  Unit        = Receiptisan::Model::ReceiptComputer::Master::Unit

  let(:csv_dir) { '../../../../../../resource/csv/master/2022' }

  describe '#load' do
    let(:loader) { described_class.new }
    let(:result) { loader.load([Pathname(csv_dir).join('b_ALL00000000.csv').expand_path(__dir__)]) }

    specify '読込結果はHashで返す' do
      expect(result).to be_instance_of Hash
    end

    specify '傷病名コードのシンボルがキーになっている' do
      expect(result.keys).to include(*%i[0000999 4375001 9599001 9170003 8847337])
    end

    specify '値は傷病名オブジェクトになっている' do
      expect(result.values).to all(be_instance_of Shoubyoumei)
    end

    describe '各傷病名オブジェクトの各属性が正しく読込まれている' do
      shared_examples '#load_shoubyoumei_master_examples' do | code_by_symbol, name, name_kana, full_name |
        specify '傷病名コードは、Shoubyoumei::Codeオブジェクトとして読込まれる' do
          expect(result[code_by_symbol].code).to be_instance_of Shoubyoumei::Code
        end

        specify '傷病名コードがCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].code).to eq Shoubyoumei::Code.of(code_by_symbol)
        end

        specify '傷病名省略漢字名称がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].name).to eq name
        end

        specify '傷病名カナ名称は、全角カナで読込まれる' do
          expect(result[code_by_symbol].name_kana).to eq name_kana
        end

        specify '傷病名漢字名称がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].full_name).to eq full_name
        end
      end

      context '＊＊　未コード化傷病名　＊＊' do
        it_behaves_like '#load_shoubyoumei_master_examples',
          _code_by_symbol  = :'0000999',
          _name            = '＊＊　未コード化傷病名　＊＊',
          _name_kana       = '＊＊　ミコードカショウビョウメイ　＊＊',
          _full_name       = '＊＊　未コード化傷病名　＊＊'
      end

      context 'もやもや病' do
        it_behaves_like '#load_shoubyoumei_master_examples',
          _code_by_symbol  = :'4375001',
          _name            = 'もやもや病',
          _name_kana       = 'モヤモヤビョウ',
          _full_name       = 'もやもや病'
      end

      context '外傷' do
        it_behaves_like '#load_shoubyoumei_master_examples',
          _code_by_symbol  = :'9599001',
          _name            = '外傷',
          _name_kana       = 'ガイショウ',
          _full_name       = '外傷'
      end

      context '足関節擦過傷' do
        it_behaves_like '#load_shoubyoumei_master_examples',
          _code_by_symbol  = :'9170003',
          _name            = '足関節擦過傷',
          _name_kana       = 'ソクカンセツサッカショウ',
          _full_name       = '足関節擦過傷'
      end

      context '高齢者ＥＢＶ陽性ＤＬＢＣＬ' do
        it_behaves_like '#load_shoubyoumei_master_examples',
          _code_by_symbol  = :'8847337',
          _name            = '高齢者ＥＢＶ陽性ＤＬＢＣＬ',
          _name_kana       = 'コウレイシャＥＢＶヨウセイビマンセイダイサイボウガタＢサイボウセイリンパシュ',
          _full_name       = '高齢者ＥＢＶ陽性びまん性大細胞型Ｂ細胞性リンパ腫'
      end
    end
  end
end
