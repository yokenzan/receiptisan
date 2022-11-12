# frozen_string_literal: true

require 'pathname'
require 'recediff'

ShinryouKouiLoader = Recediff::Model::ReceiptComputer::Master::Loader::ShinryouKouiLoader
Version            = Recediff::Model::ReceiptComputer::Master::Version
ShinryouKoui       = Recediff::Model::ReceiptComputer::Master::Treatment::ShinryouKoui
Unit               = Recediff::Model::ReceiptComputer::Master::Unit

RSpec.describe ShinryouKouiLoader do
  let(:csv_dir) { '../../../../../../resource/csv/master/0000' }

  describe '#load' do
    let(:loader) { ShinryouKouiLoader.new }
    let(:result) { loader.load(Version::V2022_R04, Pathname(csv_dir).join('s_ALL00000000.csv').expand_path(__dir__)) }

    specify '読込結果はHashで返す' do
      expect(result).to be_instance_of Hash
    end
    specify '診療行為コードのシンボルがキーになっている' do
      expect(result.keys).to include(:'111000110', :'140009310', :'160000190', :'170000410')
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
        it_behaves_like '#load_shinryou_koui_master_examples', :'111000110', '初診料', 'ショシンリョウ', nil, '初診料'
      end
      context '人工呼吸' do
        it_behaves_like '#load_shinryou_koui_master_examples', :'140009310', '人工呼吸', 'ジンコウコキュウ', Unit.find_by_code('1'), '人工呼吸'
      end
      context '検査逓減' do
        it_behaves_like '#load_shinryou_koui_master_examples', :'160000190', '検査逓減', 'ケンサテイゲン', nil, '検査逓減'
      end
      context '単純撮影（イ）の写真診断' do
        it_behaves_like '#load_shinryou_koui_master_examples', :'170000410', '単純撮影（イ）の写真診断', 'タンジュンサツエイノシャシンシンダン', Unit.find_by_code('6'), '単純撮影（頭部、胸部、腹部又は脊椎）の写真診断'
      end
    end
  end
end
