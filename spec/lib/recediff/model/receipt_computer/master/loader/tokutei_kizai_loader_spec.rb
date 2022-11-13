# frozen_string_literal: true

require 'pathname'
require 'recediff'

TokuteiKizaiLoader = Recediff::Model::ReceiptComputer::Master::Loader::TokuteiKizaiLoader
Version            = Recediff::Model::ReceiptComputer::Master::Version
TokuteiKizai       = Recediff::Model::ReceiptComputer::Master::Treatment::TokuteiKizai
Unit               = Recediff::Model::ReceiptComputer::Master::Unit

RSpec.describe TokuteiKizaiLoader do
  let(:csv_dir) { '../../../../../../resource/csv/master/2022' }

  describe '#load' do
    let(:loader) { TokuteiKizaiLoader.new }
    let(:result) { loader.load(Pathname(csv_dir).join('t_ALL00000000.csv').expand_path(__dir__)) }

    specify '読込結果はHashで返す' do
      expect(result).to be_instance_of Hash
    end
    specify '医薬品コードのシンボルがキーになっている' do
      expect(result.keys).to include(*%i[710010001 700010000 700600000 739200000 770020070 770030070])
    end
    specify '値は医薬品オブジェクトになっている' do
      expect(result.values).to all(be_instance_of TokuteiKizai)
    end

    describe '各医薬品オブジェクトの各属性が正しく読込まれている' do
      shared_examples '#load_tokutei_kizai_master_examples' do | code_by_symbol, name, name_kana, unit, full_name |
        specify '医薬品コードは、TokuteiKizai::Codeオブジェクトとして読込まれる' do
          expect(result[code_by_symbol].code).to be_instance_of TokuteiKizai::Code
        end
        specify '医薬品コードがCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].code).to eq TokuteiKizai::Code.of(code_by_symbol)
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
          expect(result[code_by_symbol].unit).to be unit
        end
        specify '剤形がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].unit).to be unit
        end
        specify '医薬品漢字名称がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].full_name).to eq full_name
        end
      end

      context '血管造影用シースイントロデューサーセット（選択的導入用）' do
        it_behaves_like '#load_tokutei_kizai_master_examples',
          _code_by_symbol  = :'710010001',
          _name            = '血管造影用シースイントロデューサーセット（選択的導入用）',
          _name_kana       = 'ケッカンゾウエイヨウシースイントロデ',
          _unit            = nil,
          _full_name       = '血管造影用シースイントロデューサーセット・選択的導入用（ガイディングカテーテルを兼ねるもの）'
      end
      context '半切' do
        it_behaves_like '#load_tokutei_kizai_master_examples',
          _code_by_symbol  = :'700010000',
          _name            = '半切',
          _name_kana       = 'ハンセツ',
          _unit            = Unit.find_by_code('6'),
          _full_name       = 'フィルム・半切'
      end
      context '眼科学的検査用フィルム' do
        it_behaves_like '#load_tokutei_kizai_master_examples',
          _code_by_symbol  = :'700600000',
          _name            = '眼科学的検査用フィルム',
          _name_kana       = 'ガンカガクテキケンサヨウフィルム',
          _unit            = Unit.find_by_code('6'),
          _full_name       = '眼科学的検査用フィルム'
      end
      context '液体酸素・定置式液化酸素貯槽（ＣＥ）' do
        it_behaves_like '#load_tokutei_kizai_master_examples',
          _code_by_symbol  = :'739200000',
          _name            = '液体酸素・定置式液化酸素貯槽（ＣＥ）',
          _name_kana       = 'エキタイサンソテイチシキエキカサンソチョ',
          _unit            = Unit.find_by_code('37'),
          _full_name       = '液体酸素・定置式液化酸素貯槽（ＣＥ）'
      end
      context '酸素補正率１．３（１気圧）' do
        it_behaves_like '#load_tokutei_kizai_master_examples',
          _code_by_symbol  = :'770020070',
          _name            = '酸素補正率１．３（１気圧）',
          _name_kana       = 'サンソホセイリツ',
          _unit            = nil,
          _full_name       = '酸素補正率１．３（１気圧）'
      end
      context '高気圧酸素加算' do
        it_behaves_like '#load_tokutei_kizai_master_examples',
          _code_by_symbol  = :'770030070',
          _name            = '高気圧酸素加算',
          _name_kana       = 'コウキアツサンソカサン',
          _unit            = Unit.find_by_code('54'),
          _full_name       = '高気圧酸素加算'
      end
    end
  end
end
