# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass, RSpec/ExampleLength, RSpec/MultipleExpectations

require 'rake'
require 'receiptisan'

RSpec.describe 'master:generate_cache' do
  let(:rakefile_path) { File.expand_path('../../Rakefile', __dir__) }
  let(:old_version) { instance_double(Receiptisan::Model::ReceiptComputer::Master::Version, year: 2022) }
  let(:previous_version) { instance_double(Receiptisan::Model::ReceiptComputer::Master::Version, year: 2023) }
  let(:latest_version) { instance_double(Receiptisan::Model::ReceiptComputer::Master::Version, year: 2024) }
  let(:loader) { instance_double(Receiptisan::Model::ReceiptComputer::Master::Loader) }

  before do
    master = Receiptisan::Model::ReceiptComputer::Master
    Rake.application = Rake::Application.new
    load rakefile_path
    allow(master::Version).to receive(:values).and_return([old_version, previous_version, latest_version])
    allow(master::Loader).to receive(:new).and_return(loader)
    allow(loader).to receive(:generate_cache)
  end

  after do
    Rake.application = nil
    ENV.delete('VERSION')
  end

  it 'デフォルトでは最新2年度に対してキャッシュ生成を実行する' do
    expect do
      Rake::Task['master:generate_cache'].invoke
    end.to output(
      "generated cache for master version 2023\n" \
      "generated cache for master version 2024\n"
    ).to_stdout

    expect(loader).to have_received(:generate_cache).with(previous_version)
    expect(loader).to have_received(:generate_cache).with(latest_version)
  end

  it 'VERSIONを指定した場合は該当年度のみ生成する' do
    ENV['VERSION'] = '2022'

    expect do
      Rake::Task['master:generate_cache'].invoke
    end.to output("generated cache for master version 2022\n").to_stdout

    expect(loader).to have_received(:generate_cache).with(old_version)
    expect(loader).not_to have_received(:generate_cache).with(previous_version)
    expect(loader).not_to have_received(:generate_cache).with(latest_version)
  end

  it 'list_versionsでバージョン一覧を表示する' do
    term_old = instance_double(Range, begin: '2022-04', end: '2023-03')
    term_previous = instance_double(Range, begin: '2023-04', end: '2024-05')
    term_latest = instance_double(Range, begin: '2024-06', end: '2026-05')
    allow(old_version).to receive(:term).and_return(term_old)
    allow(previous_version).to receive(:term).and_return(term_previous)
    allow(latest_version).to receive(:term).and_return(term_latest)

    expect do
      Rake::Task['master:list_versions'].invoke
    end.to output(
      "2022: 2022-04～2023-03\n" \
      "2023: 2023-04～2024-05\n" \
      "2024: 2024-06～2026-05\n"
    ).to_stdout
  end
end
# rubocop:enable RSpec/DescribeClass, RSpec/ExampleLength, RSpec/MultipleExpectations
