# frozen_string_literal: true

require 'pathname'
require 'receiptisan'

ShuushokugoLoader = Receiptisan::Model::ReceiptComputer::Master::Loader::ShuushokugoLoader
Version           = Receiptisan::Model::ReceiptComputer::Master::Version
Shuushokugo       = Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo
Unit              = Receiptisan::Model::ReceiptComputer::Master::Unit

RSpec.describe ShuushokugoLoader do
  let(:csv_dir) { '../../../../../../resource/csv/master/2022' }

  describe '#load' do
    let(:loader) { described_class.new }
    let(:result) { loader.load([Pathname(csv_dir).join('z_ALL00000000.csv').expand_path(__dir__)]) }

    specify '読込結果はHashで返す' do
      expect(result).to be_instance_of Hash
    end

    specify '修飾語コードのシンボルがキーになっている' do
      expect(result.keys).to include(*%i[1298 2060 3088 4001 5029 6026 7055 8048])
    end

    specify '値は修飾語オブジェクトになっている' do
      expect(result.values).to all(be_instance_of Shuushokugo)
    end

    describe '各修飾語オブジェクトの各属性が正しく読込まれている' do
      shared_examples '#load_shuushokugo_master_examples' do | code_by_symbol, name, name_kana, category |
        let(:target) { result[code_by_symbol] }

        specify '修飾語コードは、Shuushokugo::Codeオブジェクトとして読込まれる' do
          expect(target.code).to be_instance_of Shuushokugo::Code
        end

        specify '修飾語コードがCSVとオブジェクトで一致する' do
          expect(target.code).to eq Shuushokugo::Code.of(code_by_symbol)
        end

        specify '修飾語漢字名称がCSVとオブジェクトで一致する' do
          expect(target.name).to eq name
        end

        specify '修飾語カナ名称は、全角カナで読込まれる' do
          expect(target.name_kana).to eq name_kana
        end

        specify '修飾語区分がCSVとオブジェクトで一致する' do
          # private method
          expect(target.__send__(:category)).to eq category
        end
      end

      context '環指末節骨' do
        it_behaves_like '#load_shuushokugo_master_examples',
          _code_by_symbol = :'1298',
          _name           = '環指末節骨',
          _name_kana      = 'カンシマッセツコツ',
          _category       = Shuushokugo::Category.find_by_code(1)
      end

      context '左右' do
        it_behaves_like '#load_shuushokugo_master_examples',
          _code_by_symbol = :'2060',
          _name           = '左右',
          _name_kana      = 'サユウ',
          _category       = Shuushokugo::Category.find_by_code(2)
      end

      context '術後' do
        it_behaves_like '#load_shuushokugo_master_examples',
          _code_by_symbol = :'3088',
          _name           = '術後',
          _name_kana      = 'ジュツゴ',
          _category       = Shuushokugo::Category.find_by_code(3)
      end

      context '亜急性' do
        it_behaves_like '#load_shuushokugo_master_examples',
          _code_by_symbol = :'4001',
          _name           = '亜急性',
          _name_kana      = 'アキュウセイ',
          _category       = Shuushokugo::Category.find_by_code(4)
      end

      context '間質性' do
        it_behaves_like '#load_shuushokugo_master_examples',
          _code_by_symbol = :'5029',
          _name           = '間質性',
          _name_kana      = 'カンシツセイ',
          _category       = Shuushokugo::Category.find_by_code(5)
      end

      context '加齢性' do
        it_behaves_like '#load_shuushokugo_master_examples',
          _code_by_symbol = :'6026',
          _name           = '加齢性',
          _name_kana      = 'カレイセイ',
          _category       = Shuushokugo::Category.find_by_code(6)
      end

      context '労作性' do
        it_behaves_like '#load_shuushokugo_master_examples',
          _code_by_symbol = :'7055',
          _name           = '労作性',
          _name_kana      = 'ロウサセイ',
          _category       = Shuushokugo::Category.find_by_code(7)
      end

      context 'の術後' do
        it_behaves_like '#load_shuushokugo_master_examples',
          _code_by_symbol = :'8048',
          _name           = 'の術後',
          _name_kana      = 'ノジュツゴ',
          _category       = Shuushokugo::Category.find_by_code(8)
      end
    end
  end
end
