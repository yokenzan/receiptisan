# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Cli::Command::SearchCommand do
  let(:command) { described_class.new }

  describe '#resolve_master_type' do
    context 'typeが指定されている場合' do
      specify '対応するSymbolを返すこと' do
        result = command.send(:resolve_master_type, 'shinryou-koui', nil)
        expect(result).to eq :shinryou_koui
      end

      specify 'shoubyoumeiに対応すること' do
        result = command.send(:resolve_master_type, 'shoubyoumei', nil)
        expect(result).to eq :shoubyoumei
      end

      specify 'shuushokugoに対応すること' do
        result = command.send(:resolve_master_type, 'shuushokugo', nil)
        expect(result).to eq :shuushokugo
      end
    end

    context 'typeが未指定でcodeが指定されている場合' do
      specify 'CodeTypeResolverに委譲すること' do
        expect(command.send(:resolve_master_type, nil, '111000110')).to eq :shinryou_koui
      end

      specify '7桁コードで傷病名を返すこと' do
        expect(command.send(:resolve_master_type, nil, '8830900')).to eq :shoubyoumei
      end

      specify '4桁コードで修飾語を返すこと' do
        expect(command.send(:resolve_master_type, nil, '2056')).to eq :shuushokugo
      end
    end

    context 'typeもcodeも未指定の場合' do
      specify 'ArgumentErrorを発生すること' do
        expect { command.send(:resolve_master_type, nil, nil) }
          .to raise_error(ArgumentError, /種別またはコードを指定してください/)
      end
    end
  end

  describe '#build_condition' do
    context '--nameと--name_exactの同時指定の場合' do
      specify 'ArgumentErrorを発生すること' do
        options = { name: '初診', name_exact: '初診料' }
        expect { command.send(:build_condition, options) }
          .to raise_error(ArgumentError, /--name と --name-exact は同時に指定できません/)
      end
    end

    context '--pointと--point_minの同時指定の場合' do
      specify '警告を出力すること' do
        options = { point: 288, point_min: 100 }
        expect { command.send(:build_condition, options) }.to output(/--point を優先します/).to_stderr
      end

      specify 'point_minが除外されること' do
        options = { point: 288, point_min: 100 }
        command.send(:build_condition, options)
        expect(options).not_to have_key(:point_min)
      end
    end

    context '--pointと--point_maxの同時指定の場合' do
      specify '警告を出力すること' do
        options = { point: 288, point_max: 500 }
        expect { command.send(:build_condition, options) }.to output(/--point を優先します/).to_stderr
      end

      specify 'point_maxが除外されること' do
        options = { point: 288, point_max: 500 }
        command.send(:build_condition, options)
        expect(options).not_to have_key(:point_max)
      end
    end

    context '--pointと--point_min/--point_maxの同時指定の場合' do
      specify '警告を出力すること' do
        options = { point: 288, point_min: 100, point_max: 500 }
        expect { command.send(:build_condition, options) }.to output(/--point を優先します/).to_stderr
      end

      specify 'point_minとpoint_maxが除外されること' do
        options = { point: 288, point_min: 100, point_max: 500 }
        command.send(:build_condition, options)
        expect(options.keys).not_to include(:point_min, :point_max)
      end
    end
  end

  describe '#call の --limit' do
    let(:master) { instance_double(Receiptisan::Model::ReceiptComputer::Master) }
    let(:items)  { Array.new(5) { | i | double("item_#{i}") } } # rubocop:disable RSpec/VerifiedDoubles

    before do
      allow(command).to receive(:load_master).and_return(master)
      searcher = instance_double(Receiptisan::Model::ReceiptComputer::Master::Search::Searcher)
      allow(Receiptisan::Model::ReceiptComputer::Master::Search::Searcher).to receive(:new).and_return(searcher)
      allow(searcher).to receive(:search).and_return(items)
      allow(command).to receive(:output)
    end

    context '--limit未指定の場合' do
      specify '全件を出力すること' do
        command.call(type: 'shinryou-koui')
        expect(command).to have_received(:output).with(items, :shinryou_koui, 'json')
      end
    end

    context '--limit 2 指定の場合' do
      specify '先頭2件のみ出力すること' do
        command.call(type: 'shinryou-koui', limit: 2)
        expect(command).to have_received(:output).with(items.first(2), :shinryou_koui, 'json')
      end
    end
  end
end
