# frozen_string_literal: true

require 'receiptisan'

Searcher  = Receiptisan::Model::ReceiptComputer::Master::Search::Searcher
Condition = Receiptisan::Model::ReceiptComputer::Master::Search::Condition unless defined?(Condition)

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Searcher do
  let(:shinryou_koui_code_class) { Receiptisan::Model::ReceiptComputer::Master::Treatment::ShinryouKoui::Code }
  let(:iyakuhin_code_class)      { Receiptisan::Model::ReceiptComputer::Master::Treatment::Iyakuhin::Code }
  let(:shoubyoumei_code_class)   { Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shoubyoumei::Code }
  let(:shuushokugo_code_class)   { Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo::Code }

  let(:shoshinryou) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::Master::Treatment::ShinryouKoui,
      code: shinryou_koui_code_class.of('111000110'), name: '初診料',
      name_kana: 'ショシンリョウ', full_name: '初診料', point: 288
    )
  end

  let(:saishinryou) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::Master::Treatment::ShinryouKoui,
      code: shinryou_koui_code_class.of('112007410'), name: '再診料',
      name_kana: 'サイシンリョウ', full_name: '再診料（診療所）', point: 73
    )
  end

  let(:gairaikannrikasan) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::Master::Treatment::ShinryouKoui,
      code: shinryou_koui_code_class.of('112015810'), name: '外来管理加算',
      name_kana: 'ガイライカンリカサン', full_name: '外来管理加算', point: 52
    )
  end

  let(:loxoprofen) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::Master::Treatment::Iyakuhin,
      code: iyakuhin_code_class.of('610463016'), name: 'ロキソプロフェン',
      name_kana: 'ロキソプロフェン', full_name: 'ロキソプロフェンナトリウム錠60mg', price: 7.80
    )
  end

  let(:acetaminophen) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::Master::Treatment::Iyakuhin,
      code: iyakuhin_code_class.of('610428032'), name: 'アセトアミノフェン',
      name_kana: 'アセトアミノフェン', full_name: 'アセトアミノフェン錠200mg', price: 6.30
    )
  end

  let(:tounyoubyou) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shoubyoumei,
      code: shoubyoumei_code_class.of('8830900'), name: '糖尿病',
      name_kana: 'トウニョウビョウ', full_name: '糖尿病'
    )
  end

  let(:kouketsuatsu) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shoubyoumei,
      code: shoubyoumei_code_class.of('8845600'), name: '高血圧症',
      name_kana: 'コウケツアツショウ', full_name: '高血圧症'
    )
  end

  let(:hidari) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo,
      code: shuushokugo_code_class.of('2056'), name: '左',
      name_kana: 'ヒダリ'
    )
  end

  let(:migi) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::Master::Diagnosis::Shuushokugo,
      code: shuushokugo_code_class.of('2048'), name: '右',
      name_kana: 'ミギ'
    )
  end

  let(:master) do
    instance_double(
      Receiptisan::Model::ReceiptComputer::Master,
      shinryou_koui: {
        shoshinryou.code.value => shoshinryou,
        saishinryou.code.value => saishinryou,
        gairaikannrikasan.code.value => gairaikannrikasan,
      },
      iyakuhin:      {
        loxoprofen.code.value => loxoprofen,
        acetaminophen.code.value => acetaminophen,
      },
      shoubyoumei:   {
        tounyoubyou.code.value => tounyoubyou,
        kouketsuatsu.code.value => kouketsuatsu,
      },
      shuushokugo:   {
        hidari.code.value => hidari,
        migi.code.value => migi,
      }
    )
  end

  let(:searcher) { described_class.new(master) }

  describe '#search' do
    context 'コード検索の場合' do
      specify '完全一致するコードで該当アイテムのみ返すこと' do
        results = searcher.search(:shinryou_koui, Condition.new(code: '111000110'))
        expect(results).to eq [shoshinryou]
      end

      specify '一致しないコードで空配列を返すこと' do
        results = searcher.search(:shinryou_koui, Condition.new(code: '999999999'))
        expect(results).to be_empty
      end
    end

    context '名前検索 (部分一致) の場合' do
      specify 'nameにヒットすること' do
        results = searcher.search(:shinryou_koui, Condition.new(name: '初診'))
        expect(results).to eq [shoshinryou]
      end

      specify 'name_kanaにヒットすること' do
        results = searcher.search(:shinryou_koui, Condition.new(name: 'サイシン'))
        expect(results).to eq [saishinryou]
      end

      specify 'full_nameにヒットすること' do
        results = searcher.search(:shinryou_koui, Condition.new(name: '診療所'))
        expect(results).to eq [saishinryou]
      end

      specify '一致しない場合は空配列を返すこと' do
        results = searcher.search(:shinryou_koui, Condition.new(name: '入院'))
        expect(results).to be_empty
      end
    end

    context '名前検索 (完全一致) の場合' do
      specify '一致する場合に該当アイテムを返すこと' do
        results = searcher.search(:shinryou_koui, Condition.new(name: '初診料', name_match_type: :exact))
        expect(results).to eq [shoshinryou]
      end

      specify 'name_kanaで完全一致検索できること' do
        results = searcher.search(:shinryou_koui, Condition.new(name: 'ショシンリョウ', name_match_type: :exact))
        expect(results).to eq [shoshinryou]
      end

      specify 'full_nameで完全一致検索できること' do
        results = searcher.search(:shinryou_koui, Condition.new(name: '再診料（診療所）', name_match_type: :exact))
        expect(results).to eq [saishinryou]
      end

      specify '部分一致だが完全一致しない場合は空配列を返すこと' do
        results = searcher.search(:shinryou_koui, Condition.new(name: '初診', name_match_type: :exact))
        expect(results).to be_empty
      end

      specify '完全一致と点数条件を併用して絞り込めること' do
        results = searcher.search(:shinryou_koui, Condition.new(name: '初診料', name_match_type: :exact, point_min: 300))
        expect(results).to be_empty
      end
    end

    context '点数フィルタの場合' do
      specify 'point_exactで点数が一致するアイテムのみ返すこと' do
        results = searcher.search(:shinryou_koui, Condition.new(point_exact: 288))
        expect(results).to eq [shoshinryou]
      end

      specify 'point_minで下限以上のアイテムを返すこと' do
        results = searcher.search(:shinryou_koui, Condition.new(point_min: 100))
        expect(results).to eq [shoshinryou]
      end

      specify 'point_maxで上限以下のアイテムを返すこと' do
        results = searcher.search(:shinryou_koui, Condition.new(point_max: 60))
        expect(results).to eq [gairaikannrikasan]
      end

      specify '範囲指定で範囲内のアイテムを返すこと' do
        results = searcher.search(:shinryou_koui, Condition.new(point_min: 50, point_max: 100))
        expect(results).to contain_exactly(saishinryou, gairaikannrikasan)
      end
    end

    context '医薬品のprice検索の場合' do
      specify 'priceが一致するアイテムのみ返すこと' do
        results = searcher.search(:iyakuhin, Condition.new(point_exact: 7.80))
        expect(results).to eq [loxoprofen]
      end

      specify 'point_exactとname_exactを併用して絞り込めること' do
        results = searcher.search(
          :iyakuhin,
          Condition.new(point_exact: 7.80, name: 'ロキソプロフェン', name_match_type: :exact)
        )
        expect(results).to eq [loxoprofen]
      end
    end

    context '複数条件の組合せの場合' do
      specify 'AND条件で絞り込むこと' do
        results = searcher.search(:shinryou_koui, Condition.new(name: '診', point_min: 200))
        expect(results).to eq [shoshinryou]
      end
    end

    context '条件なしの場合' do
      specify '全件返すこと' do
        results = searcher.search(:shinryou_koui, Condition.new)
        expect(results).to contain_exactly(shoshinryou, saishinryou, gairaikannrikasan)
      end
    end

    context '種別と一致しないコードで検索した場合' do
      specify '医薬品マスターで診療行為コードを検索すると空配列を返すこと' do
        results = searcher.search(:iyakuhin, Condition.new(code: '111000110'))
        expect(results).to be_empty
      end
    end

    context '傷病名検索の場合' do
      specify '名前で傷病名を検索できること' do
        results = searcher.search(:shoubyoumei, Condition.new(name: '糖尿'))
        expect(results).to eq [tounyoubyou]
      end

      specify 'コードで傷病名を検索できること' do
        results = searcher.search(:shoubyoumei, Condition.new(code: '8830900'))
        expect(results).to eq [tounyoubyou]
      end

      specify '条件なしで全件返すこと' do
        results = searcher.search(:shoubyoumei, Condition.new)
        expect(results).to contain_exactly(tounyoubyou, kouketsuatsu)
      end

      specify '点数条件を指定しても全件返すこと' do
        results = searcher.search(:shoubyoumei, Condition.new(point_min: 100))
        expect(results).to contain_exactly(tounyoubyou, kouketsuatsu)
      end

      specify 'point_exactを指定しても全件返すこと' do
        results = searcher.search(:shoubyoumei, Condition.new(point_exact: 100))
        expect(results).to contain_exactly(tounyoubyou, kouketsuatsu)
      end
    end

    context '修飾語検索の場合' do
      specify '名前で修飾語を検索できること' do
        results = searcher.search(:shuushokugo, Condition.new(name: '左'))
        expect(results).to eq [hidari]
      end

      specify 'カナ名で修飾語を検索できること' do
        results = searcher.search(:shuushokugo, Condition.new(name: 'ミギ'))
        expect(results).to eq [migi]
      end

      specify '条件なしで全件返すこと' do
        results = searcher.search(:shuushokugo, Condition.new)
        expect(results).to contain_exactly(hidari, migi)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
