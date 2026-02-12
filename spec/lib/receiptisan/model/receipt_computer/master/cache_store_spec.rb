# frozen_string_literal: true

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations

require 'tmpdir'
require 'pathname'
require 'receiptisan'
require 'logger'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::CacheStore do
  let(:logger) { Logger.new(nil) }
  let(:store) { described_class.new(logger) }

  describe '#detect_cache_path' do
    it 'master用のキャッシュパスを返す' do
      csv_path = Pathname('/tmp/2024/y_sample.csv')
      csv_paths = {
        shinryou_koui_csv_path: [csv_path],
        iyakuhin_csv_path:      [csv_path],
        tokutei_kizai_csv_path: [csv_path],
        comment_csv_path:       [csv_path],
        shoubyoumei_csv_path:   [csv_path],
        shuushokugo_csv_path:   [csv_path],
      }

      expect(store.detect_cache_path(csv_paths)).to eq(Pathname('/tmp/2024/.cache/master.marshal'))
    end
  end

  describe '#detect_type_cache_path' do
    it '型別キャッシュパスを返す' do
      csv_path = Pathname('/tmp/2024/y_sample.csv')
      csv_paths = {
        shinryou_koui_csv_path: [csv_path],
        iyakuhin_csv_path:      [csv_path],
        tokutei_kizai_csv_path: [csv_path],
        comment_csv_path:       [csv_path],
        shoubyoumei_csv_path:   [csv_path],
        shuushokugo_csv_path:   [csv_path],
      }

      expect(store.detect_type_cache_path(csv_paths, :iyakuhin)).to eq(Pathname('/tmp/2024/.cache/iyakuhin.marshal'))
    end
  end

  describe '#read' do
    it '有効なキャッシュがあればオブジェクトを返す' do
      Dir.mktmpdir do | dir |
        year_dir = Pathname(dir).join('2024')
        csv_path = year_dir.join('y_sample.csv')
        cache_path = year_dir.join('.cache', 'master.marshal')
        year_dir.mkpath
        csv_path.write('"A","B"' + "\n")
        cache_path.dirname.mkpath
        cache_path.binwrite(Marshal.dump({ cached: true }))

        csv_paths = {
          shinryou_koui_csv_path: [csv_path],
          iyakuhin_csv_path:      [csv_path],
          tokutei_kizai_csv_path: [csv_path],
          comment_csv_path:       [csv_path],
          shoubyoumei_csv_path:   [csv_path],
          shuushokugo_csv_path:   [csv_path],
        }

        expect(store.read(cache_path, csv_paths)).to eq({ cached: true })
      end
    end
  end

  describe '#write' do
    it 'キャッシュファイルを書き込む' do
      Dir.mktmpdir do | dir |
        cache_path = Pathname(dir).join('2024', '.cache', 'master.marshal')

        store.write(cache_path, { master: true })

        expect(cache_path).to exist
        # rubocop:disable Security/MarshalLoad
        expect(Marshal.load(cache_path.binread)).to eq({ master: true })
        # rubocop:enable Security/MarshalLoad
      end
    end
  end
end

# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
