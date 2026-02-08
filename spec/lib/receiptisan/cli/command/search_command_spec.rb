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
    end

    context 'typeが未指定でcodeが指定されている場合' do
      specify '先頭桁1で診療行為を返すこと' do
        expect(command.send(:resolve_master_type, nil, '111000110')).to eq :shinryou_koui
      end

      specify '先頭桁6で医薬品を返すこと' do
        expect(command.send(:resolve_master_type, nil, '610463016')).to eq :iyakuhin
      end

      specify '先頭桁7で特定器材を返すこと' do
        expect(command.send(:resolve_master_type, nil, '700010000')).to eq :tokutei_kizai
      end

      specify '先頭桁8でコメントを返すこと' do
        expect(command.send(:resolve_master_type, nil, '810000001')).to eq :comment
      end

      specify '判定できない先頭桁でArgumentErrorを発生すること' do
        expect { command.send(:resolve_master_type, nil, '999999999') }
          .to raise_error(ArgumentError, /種別を判定できません/)
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
end
