# frozen_string_literal: true

require 'pathname'
require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Loader::ShinryouKouiLoader do
  Version      = Receiptisan::Model::ReceiptComputer::Master::Version
  ShinryouKoui = Receiptisan::Model::ReceiptComputer::Master::Treatment::ShinryouKoui
  Unit         = Receiptisan::Model::ReceiptComputer::Master::Unit

  describe '#load' do
    let(:result) { described_class.new.load(Version::V2022_R04, Pathname('../../../../../../resource/csv/master/2022').join('s_ALL00000000.csv').expand_path(__dir__)) }
    let(:result_v2020) { described_class.new.load(Version::V2020_R02, Pathname('../../../../../../resource/csv/master').join('2020/s_ALL00000000.csv').expand_path(__dir__)) }
    let(:result_v2022) { described_class.new.load(Version::V2022_R04, Pathname('../../../../../../resource/csv/master').join('2022/s_ALL00000000.csv').expand_path(__dir__)) }

    specify '読込結果はHashで返す' do
      expect(result).to be_instance_of Hash
    end

    specify '診療行為コードのシンボルがキーになっている' do
      expect(result.keys).to include(*%i[111000110 140009310 160000190 170000410])
    end

    specify '値は診療行為オブジェクトになっている' do
      expect(result.values).to all(be_instance_of ShinryouKoui)
    end

    describe '各診療行為オブジェクトの各属性が正しく読込まれている' do
      shared_examples '#load_shinryou_koui_master_examples' do | code_by_symbol, name, name_kana, unit, full_name |
        specify '診療行為コードは、ShinryouKoui::Codeオブジェクトとして読込まれる' do
          expect(result[code_by_symbol].code).to be_instance_of ShinryouKoui::Code
        end

        specify '診療行為コードがCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].code).to eq ShinryouKoui::Code.of(code_by_symbol)
        end

        specify '診療行為省略漢字名称がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].name).to eq name
        end

        specify '診療行為カナ名称は、全角カナで読込まれる' do
          expect(result[code_by_symbol].name_kana).to eq name_kana
        end

        specify 'データ規格コードがCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].unit).to be unit
        end

        specify '診療行為漢字名称がCSVとオブジェクトで一致する' do
          expect(result[code_by_symbol].full_name).to eq full_name
        end
      end

      context '初診料' do
        it_behaves_like '#load_shinryou_koui_master_examples',
          _code_by_symbol = :'111000110',
          _name           = '初診料',
          _name_kana      = 'ショシンリョウ',
          _unit           = nil,
          _full_name      = '初診料'
      end

      context '人工呼吸' do
        it_behaves_like '#load_shinryou_koui_master_examples',
          _code_by_symbol = :'140009310',
          _name           = '人工呼吸',
          _name_kana      = 'ジンコウコキュウ',
          _unit           = Unit.find_by_code('1'),
          _full_name      = '人工呼吸'
      end

      context '検査逓減' do
        it_behaves_like '#load_shinryou_koui_master_examples',
          _code_by_symbol = :'160000190',
          _name           = '検査逓減',
          _name_kana      = 'ケンサテイゲン',
          _unit           = nil,
          _full_name      = '検査逓減'
      end

      context '単純撮影（イ）の写真診断' do
        it_behaves_like '#load_shinryou_koui_master_examples',
          _code_by_symbol = :'170000410',
          _name           = '単純撮影（イ）の写真診断',
          _name_kana      = 'タンジュンサツエイノシャシンシンダン',
          _unit           = Unit.find_by_code('6'),
          _full_name      = '単純撮影（頭部、胸部、腹部又は脊椎）の写真診断'
      end
    end

    describe '初診料の点数の変更が正しく切替わる' do
      let(:shoshinryou_code) { :'111000110' }

      specify '2022年度、初診料の点数は282点であること' do
        expect(result_v2022[shoshinryou_code].point).to eq 282
      end

      specify '2022年度、初診料の点数は288点であること' do
        expect(result_v2020[shoshinryou_code].point).to eq 288
      end
    end

    describe '処方箋料の名称の変更が正しく切替わる' do
      let(:shohousenryou_code) { :'120002910' }

      specify '2022年度、名称は"処方箋料（リフィル以外・その他）"であること' do
        expect(result_v2022[shohousenryou_code].name).to eq '処方箋料（リフィル以外・その他）'
      end

      specify '2022年度、名称は"処方箋料（その他）"であること' do
        expect(result_v2020[shohousenryou_code].name).to eq '処方箋料（その他）'
      end
    end
  end
end
