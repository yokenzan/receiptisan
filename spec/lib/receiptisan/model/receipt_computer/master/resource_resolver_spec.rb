# frozen_string_literal: true

require 'pathname'
require 'receiptisan'

ResourceResolver = Receiptisan::Model::ReceiptComputer::Master::ResourceResolver
Version          = Receiptisan::Model::ReceiptComputer::Master::Version

RSpec.describe ResourceResolver do
  let!(:resolver) { described_class.new }

  describe '#detect_csv_files' do
    describe '各マスターCSVのパスをHashで返す' do
      let(:resolved_paths) { resolver.detect_csv_files(Version.values.sample) }

      shared_examples 'CSV file path result specification' do | master, file_prefixes |
        let(:key) { "#{master}_csv_path".intern }

        specify '固定のキーでアクセスできる' do
          expect(resolved_paths).to have_key(key)
        end

        specify 'Pathnameの配列を返す' do
          expect(resolved_paths[key]).to all(an_instance_of(Pathname))
        end

        specify 'Pathnameは絶対パスになっている' do
          expect(resolved_paths[key]).to all(be_absolute)
        end

        specify '存在するファイルのパスを返す' do
          expect(resolved_paths[key]).to all(be_exist)
        end

        specify 'ファイルである' do
          expect(resolved_paths[key]).to all(be_file)
        end

        specify "ファイル名は'#{file_prefixes.join('、')}'ではじまる" do
          file_prefixes.each { | prefix | expect(resolved_paths[key].map { | path | path.basename.to_path }).to include(start_with(prefix)) }
        end
      end

      context '診療行為マスター' do
        it_behaves_like 'CSV file path result specification', _master = 'shinryou_koui', _file_prefixes = %w[s k]
      end

      context '医薬品マスター' do
        it_behaves_like 'CSV file path result specification', _master = 'iyakuhin', _file_prefix = %w[y]
      end

      context '特定器材マスター' do
        it_behaves_like 'CSV file path result specification', _master = 'tokutei_kizai', _file_prefix = %w[t]
      end

      context 'コメントマスター' do
        it_behaves_like 'CSV file path result specification', _master = 'comment', _file_prefix = %w[c]
      end

      context '傷病名マスター' do
        it_behaves_like 'CSV file path result specification', _master = 'shoubyoumei', _file_prefix = %w[b]
      end

      context '修飾語マスター' do
        it_behaves_like 'CSV file path result specification', _master = 'shuushokugo', _file_prefix = %w[z]
      end
    end

    describe '点数表の版に対応するCSVのパスを返す' do
      context '2022年度版点数表' do
        specify '診療行為マスターCSVの親ディレクトリ名に点数表の版年度が含まれる' do
          expect(resolver.detect_csv_files(Version::V2022_R04).values.flat_map { | paths | paths.map { | path | path.parent.basename.to_path } }).to all(eq '2022')
        end
      end

      context '2020年度版の点数表の場合' do
        specify '診療行為マスターCSVの親ディレクトリ名に点数表の版年度が含まれる' do
          expect(resolver.detect_csv_files(Version::V2020_R02).values.flat_map { | paths | paths.map { | path | path.parent.basename.to_path } }).to all(eq '2020')
        end
      end

      context '2019年度版の点数表の場合' do
        specify '診療行為マスターCSVの親ディレクトリ名に点数表の版年度が含まれる' do
          expect(resolver.detect_csv_files(Version::V2019_R01).values.flat_map { | paths | paths.map { | path | path.parent.basename.to_path } }).to all(eq '2019')
        end
      end

      context '2018年度版の点数表の場合' do
        specify '診療行為マスターCSVの親ディレクトリ名に点数表の版年度が含まれる' do
          expect(resolver.detect_csv_files(Version::V2018_H30).values.flat_map { | paths | paths.map { | path | path.parent.basename.to_path } }).to all(eq '2018')
        end
      end
    end
  end
end
