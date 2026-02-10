# frozen_string_literal: true

require 'pathname'
require 'tmpdir'
require 'fileutils'
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

    describe 'プレフィックスマッチの厳密性' do
      let(:tmpdir) { Dir.mktmpdir }
      let(:version_dir) { File.join(tmpdir, '2024') }

      before do
        FileUtils.mkdir_p(version_dir)
      end

      after do
        FileUtils.remove_entry(tmpdir)
      end

      context 'プレフィックス直後に区切り文字がないファイルが存在する場合' do
        before do
          # 正規のファイル
          FileUtils.touch(File.join(version_dir, 's_ALL20240412.csv'))
          # プレフィックスで始まるが区切り文字がない無関係ファイル
          FileUtils.touch(File.join(version_dir, 'sample.csv'))
        end

        let(:result) { resolver.detect_csv_files(Version::V2024_R06, tmpdir) }
        let(:filenames) { result[:shinryou_koui_csv_path].map { | path | path.basename.to_path } }

        specify '正規のファイルは検出されること' do
          expect(filenames).to include('s_ALL20240412.csv')
        end

        specify '区切り文字がないファイルは検出されないこと' do
          expect(filenames).not_to include('sample.csv')
        end
      end

      context '正規のプレフィックスパターンのファイルのみ存在する場合' do
        before do
          FileUtils.touch(File.join(version_dir, 's_ALL20240412.csv'))
          FileUtils.touch(File.join(version_dir, 'k.csv'))
          FileUtils.touch(File.join(version_dir, 'y_ALL20240417.csv'))
          FileUtils.touch(File.join(version_dir, 't_ALL20240315.csv'))
          FileUtils.touch(File.join(version_dir, 'c_ALL20240412.csv'))
          FileUtils.touch(File.join(version_dir, 'b_20240101.txt'))
          FileUtils.touch(File.join(version_dir, 'z_20240101.txt'))
        end

        let(:result) { resolver.detect_csv_files(Version::V2024_R06, tmpdir) }

        specify '診療行為マスターファイルが検出されること' do
          expect(result[:shinryou_koui_csv_path]).not_to be_empty
        end

        specify '医薬品マスターファイルが検出されること' do
          expect(result[:iyakuhin_csv_path]).not_to be_empty
        end

        specify '特定器材マスターファイルが検出されること' do
          expect(result[:tokutei_kizai_csv_path]).not_to be_empty
        end

        specify 'コメントマスターファイルが検出されること' do
          expect(result[:comment_csv_path]).not_to be_empty
        end

        specify '傷病名マスターファイルが検出されること' do
          expect(result[:shoubyoumei_csv_path]).not_to be_empty
        end

        specify '修飾語マスターファイルが検出されること' do
          expect(result[:shuushokugo_csv_path]).not_to be_empty
        end
      end
    end
  end
end
