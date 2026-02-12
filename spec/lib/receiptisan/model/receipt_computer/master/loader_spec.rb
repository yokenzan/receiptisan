# frozen_string_literal: true

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations

require 'tmpdir'
require 'pathname'
require 'receiptisan'
require 'logger'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Loader do
  let(:logger) { Logger.new(nil) }
  let(:version) { instance_double(Receiptisan::Model::ReceiptComputer::Master::Version, year: 2024) }

  describe '#load' do
    it 'キャッシュがなければマスターをロードするがキャッシュは作成しない' do
      Dir.mktmpdir do | dir |
        year_dir  = Pathname(dir).join('2024')
        csv_path  = year_dir.join('y_sample.csv')
        cache_dir = year_dir.join('.cache')
        cache_path = cache_dir.join('master.marshal')
        year_dir.mkpath
        csv_path.write('"A","B"' + "\n")

        resolver = instance_double(
          Receiptisan::Model::ReceiptComputer::Master::ResourceResolver,
          detect_csv_files: {
            shinryou_koui_csv_path: [csv_path],
            iyakuhin_csv_path:      [csv_path],
            tokutei_kizai_csv_path: [csv_path],
            comment_csv_path:       [csv_path],
            shoubyoumei_csv_path:   [csv_path],
            shuushokugo_csv_path:   [csv_path],
          }
        )
        loader = described_class.new(resolver, logger)
        allow(loader).to receive(:load_from_version_and_csv).and_return({ loaded: :master })

        result = loader.load(version)

        expect(result).to eq({ loaded: :master })
        expect(cache_path).not_to exist
      end
    end

    it 'キャッシュがない場合はキャッシュ生成タスクを案内する警告を出す' do
      Dir.mktmpdir do | dir |
        year_dir = Pathname(dir).join('2024')
        csv_path = year_dir.join('y_sample.csv')
        cache_path = year_dir.join('.cache', 'master.marshal')
        year_dir.mkpath
        csv_path.write('"A","B"' + "\n")

        resolver = instance_double(
          Receiptisan::Model::ReceiptComputer::Master::ResourceResolver,
          detect_csv_files: {
            shinryou_koui_csv_path: [csv_path],
            iyakuhin_csv_path:      [csv_path],
            tokutei_kizai_csv_path: [csv_path],
            comment_csv_path:       [csv_path],
            shoubyoumei_csv_path:   [csv_path],
            shuushokugo_csv_path:   [csv_path],
          }
        )
        custom_logger = instance_double(Logger)
        allow(custom_logger).to receive(:info)
        allow(custom_logger).to receive(:warn)
        loader = described_class.new(resolver, custom_logger)
        allow(loader).to receive(:load_from_version_and_csv).and_return({ loaded: :master })

        loader.load(version)

        expect(custom_logger).to have_received(:warn).with("master cache not found: #{cache_path}")
        expect(custom_logger).to have_received(:warn).with('to generate cache, run: rake master:generate_cache')
      end
    end

    it 'キャッシュが有効ならキャッシュを返し再ロードしない' do
      Dir.mktmpdir do | dir |
        year_dir   = Pathname(dir).join('2024')
        csv_path   = year_dir.join('y_sample.csv')
        cache_dir  = year_dir.join('.cache')
        cache_path = cache_dir.join('master.marshal')
        year_dir.mkpath
        csv_path.write('"A","B"' + "\n")
        cache_dir.mkpath
        cache_path.binwrite(Marshal.dump({ cached: true }))

        resolver = instance_double(
          Receiptisan::Model::ReceiptComputer::Master::ResourceResolver,
          detect_csv_files: {
            shinryou_koui_csv_path: [csv_path],
            iyakuhin_csv_path:      [csv_path],
            tokutei_kizai_csv_path: [csv_path],
            comment_csv_path:       [csv_path],
            shoubyoumei_csv_path:   [csv_path],
            shuushokugo_csv_path:   [csv_path],
          }
        )
        loader = described_class.new(resolver, logger)
        allow(loader).to receive(:load_from_version_and_csv)

        result = loader.load(version)

        expect(result).to eq({ cached: true })
        expect(loader).not_to have_received(:load_from_version_and_csv)
      end
    end

    it 'CSVが更新されてキャッシュが古ければ再ロードする' do
      Dir.mktmpdir do | dir |
        year_dir   = Pathname(dir).join('2024')
        csv_path   = year_dir.join('y_sample.csv')
        cache_dir  = year_dir.join('.cache')
        cache_path = cache_dir.join('master.marshal')
        year_dir.mkpath
        csv_path.write('"A","B"' + "\n")
        cache_dir.mkpath
        cache_path.binwrite(Marshal.dump({ cached: true }))
        File.utime(Time.now - 10, Time.now - 10, cache_path.to_path)
        File.utime(Time.now, Time.now, csv_path.to_path)

        resolver = instance_double(
          Receiptisan::Model::ReceiptComputer::Master::ResourceResolver,
          detect_csv_files: {
            shinryou_koui_csv_path: [csv_path],
            iyakuhin_csv_path:      [csv_path],
            tokutei_kizai_csv_path: [csv_path],
            comment_csv_path:       [csv_path],
            shoubyoumei_csv_path:   [csv_path],
            shuushokugo_csv_path:   [csv_path],
          }
        )
        loader = described_class.new(resolver, logger)
        allow(loader).to receive(:load_from_version_and_csv).and_return({ reloaded: true })

        result = loader.load(version)

        expect(result).to eq({ reloaded: true })
        expect(loader).to have_received(:load_from_version_and_csv)
      end
    end
  end

  describe '#load_type' do
    it '型別キャッシュが有効ならキャッシュを返し再ロードしない' do
      Dir.mktmpdir do | dir |
        year_dir   = Pathname(dir).join('2024')
        csv_path   = year_dir.join('y_sample.csv')
        cache_dir  = year_dir.join('.cache')
        cache_path = cache_dir.join('iyakuhin.marshal')
        year_dir.mkpath
        csv_path.write('"A","B"' + "\n")
        cache_dir.mkpath
        cache_path.binwrite(Marshal.dump({ cached: :iyakuhin }))

        resolver = instance_double(
          Receiptisan::Model::ReceiptComputer::Master::ResourceResolver,
          detect_csv_files: {
            shinryou_koui_csv_path: [csv_path],
            iyakuhin_csv_path:      [csv_path],
            tokutei_kizai_csv_path: [csv_path],
            comment_csv_path:       [csv_path],
            shoubyoumei_csv_path:   [csv_path],
            shuushokugo_csv_path:   [csv_path],
          }
        )
        loader = described_class.new(resolver, logger)
        allow(loader).to receive(:load_type_from_csv_paths)

        result = loader.load_type(version, :iyakuhin)

        expect(result).to eq({ cached: :iyakuhin })
        expect(loader).not_to have_received(:load_type_from_csv_paths)
      end
    end

    it '型別キャッシュがなければロードするがキャッシュは作成しない' do
      Dir.mktmpdir do | dir |
        year_dir   = Pathname(dir).join('2024')
        csv_path   = year_dir.join('y_sample.csv')
        cache_dir  = year_dir.join('.cache')
        cache_path = cache_dir.join('iyakuhin.marshal')
        year_dir.mkpath
        csv_path.write('"A","B"' + "\n")

        resolver = instance_double(
          Receiptisan::Model::ReceiptComputer::Master::ResourceResolver,
          detect_csv_files: {
            shinryou_koui_csv_path: [csv_path],
            iyakuhin_csv_path:      [csv_path],
            tokutei_kizai_csv_path: [csv_path],
            comment_csv_path:       [csv_path],
            shoubyoumei_csv_path:   [csv_path],
            shuushokugo_csv_path:   [csv_path],
          }
        )
        loader = described_class.new(resolver, logger)
        allow(loader).to receive(:load_type_from_csv_paths).and_return({ loaded: :iyakuhin })

        result = loader.load_type(version, :iyakuhin)

        expect(result).to eq({ loaded: :iyakuhin })
        expect(cache_path).not_to exist
      end
    end
  end

  describe '#generate_cache' do
    it '全体キャッシュと型別キャッシュを生成する' do
      Dir.mktmpdir do | dir |
        year_dir   = Pathname(dir).join('2024')
        csv_path   = year_dir.join('y_sample.csv')
        cache_dir  = year_dir.join('.cache')
        cache_path = cache_dir.join('master.marshal')
        year_dir.mkpath
        csv_path.write('"A","B"' + "\n")

        resolver = instance_double(
          Receiptisan::Model::ReceiptComputer::Master::ResourceResolver,
          detect_csv_files: {
            shinryou_koui_csv_path: [csv_path],
            iyakuhin_csv_path:      [csv_path],
            tokutei_kizai_csv_path: [csv_path],
            comment_csv_path:       [csv_path],
            shoubyoumei_csv_path:   [csv_path],
            shuushokugo_csv_path:   [csv_path],
          }
        )
        loader = described_class.new(resolver, logger)
        allow(loader).to receive(:load_from_version_and_csv).and_return({ master: true })
        allow(loader).to receive(:load_type_from_csv_paths) { | _version, type, _csv_paths | { type => true } }

        loader.generate_cache(version)

        expect(cache_path).to exist
        described_class::MASTER_TYPES.each do | type |
          expect(cache_dir.join("#{type}.marshal")).to exist
        end
      end
    end
  end
end

# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
