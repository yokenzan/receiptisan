# frozen_string_literal: true

require 'pathname'
require 'recediff'

IyakuhinLoader = Recediff::Model::ReceiptComputer::Master::Loader::IyakuhinLoader
Version        = Recediff::Model::ReceiptComputer::Master::Version
Iyakuhin       = Recediff::Model::ReceiptComputer::Master::Treatment::Iyakuhin
Unit           = Recediff::Model::ReceiptComputer::Master::Unit

RSpec.describe IyakuhinLoader do
  let(:csv_dir) { '../../../../../../resource/csv/master/2022' }

  describe '#load' do
    let(:loader) { described_class.new }
    let(:result) { loader.load(Pathname(csv_dir).join('y_ALL00000000.csv').expand_path(__dir__)) }

    specify '読込結果はHashで返す' do
      expect(result).to be_instance_of Hash
    end

    specify '医薬品コードのシンボルがキーになっている' do
      expect(result.keys).to include(*%i[610406079 620000237 630010002 620008965])
    end

    specify '値は医薬品オブジェクトになっている' do
      expect(result.values).to all(be_instance_of Iyakuhin)
    end

    describe '各医薬品オブジェクトの各属性が正しく読込まれている' do
      shared_examples '#load_iyakuhin_master_examples' do | code_by_symbol, name, name_kana, unit, chuusha_youryou, dosage_form, full_name | # rubocop:disable Metrics/ParameterLists
        specify '医薬品コードは、Iyakuhin::Codeオブジェクトとして読込まれる' do
          expect(result[code_by_symbol].code).to be_instance_of Iyakuhin::Code
        end

        specify '医薬品コードがCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].code).to eq Iyakuhin::Code.of(code_by_symbol)
        end

        specify '医薬品省略漢字名称がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].name).to eq name
        end

        specify '医薬品カナ名称は、全角カナで読込まれる' do
          expect(result[code_by_symbol].name_kana).to eq name_kana
        end

        specify '単位がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].unit).to be unit
        end

        specify '注射容量がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].chuusha_youryou).to be chuusha_youryou
        end

        specify '剤形がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].dosage_form).to be dosage_form
        end

        specify '医薬品漢字名称がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].full_name).to eq full_name
        end
      end

      context 'ガスター散２％' do
        it_behaves_like '#load_iyakuhin_master_examples',
          _code_by_symbol  = :'610406079',
          _name            = 'ガスター散２％',
          _name_kana       = 'ガスターサン2%',
          _unit            = Unit.find_by_code('33'),
          _chuusha_youryou = nil,
          _dosage_form     = 1,
          _full_name       = 'ガスター散２％'
      end

      context '生理食塩液　１．３Ｌ' do
        it_behaves_like '#load_iyakuhin_master_examples',
          _code_by_symbol  = :'620000237',
          _name            = '生理食塩液　１．３Ｌ',
          _name_kana       = 'セイリショクエンエキ',
          _unit            = Unit.find_by_code('20'),
          _chuusha_youryou = 1300,
          _dosage_form     = 4,
          _full_name       = '生理食塩液'
      end

      context '薬剤料逓減（９０／１００）（内服薬）' do
        it_behaves_like '#load_iyakuhin_master_examples',
          _code_by_symbol  = :'630010002',
          _name            = '薬剤料逓減（９０／１００）（内服薬）',
          _name_kana       = 'ヤクザイリヨウテイゲン',
          _unit            = nil,
          _chuusha_youryou = nil,
          _dosage_form     = 3,
          _full_name       = '薬剤料逓減（９０／１００）（内服薬）'
      end

      context 'アンテベート軟膏０．０５％' do
        it_behaves_like '#load_iyakuhin_master_examples',
          _code_by_symbol  = :'620008965',
          _name            = 'アンテベート軟膏０．０５％',
          _name_kana       = 'アンテベートナンコウ0.05%',
          _unit            = Unit.find_by_code('33'),
          _chuusha_youryou = nil,
          _dosage_form     = 6,
          _full_name       = 'アンテベート軟膏０．０５％'
      end
    end
  end
end
