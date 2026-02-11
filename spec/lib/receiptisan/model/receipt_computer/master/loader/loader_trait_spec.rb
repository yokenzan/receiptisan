# frozen_string_literal: true

# rubocop:disable RSpec/ExampleLength

require 'tmpdir'
require 'pathname'
require 'receiptisan'
require 'logger'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Loader::LoaderTrait do
  let(:logger) { Logger.new(nil) }

  let(:dummy_loader_class) do
    Class.new do
      include Receiptisan::Model::ReceiptComputer::Master::Loader::LoaderTrait

      def initialize(logger)
        @logger = logger
      end

      private

      attr_reader :logger
    end
  end

  let(:loader) { dummy_loader_class.new(logger) }

  describe '#foreach' do
    it 'UTF-8変換済みファイルがある場合はそちらを読み込む' do
      Dir.mktmpdir do | dir |
        csv_path  = Pathname(dir).join('y_sample.csv')
        utf8_dir  = Pathname(dir).join('utf8')
        utf8_path = utf8_dir.join('y_sample.csv')

        csv_path.write('"A","B"' + "\n".encode('Shift_JIS'), mode: 'wb')
        utf8_dir.mkpath
        utf8_path.write('"U","T","F","8"' + "\n")

        rows = []
        loader.foreach([csv_path]) { | values | rows << values }

        expect(rows).to eq([%w[U T F 8]])
      end
    end

    it 'UTF-8変換済みファイルがなければShift_JISのCSVを読み込む' do
      Dir.mktmpdir do | dir |
        csv_path = Pathname(dir).join('y_sample.csv')
        csv_path.write('"A","B"' + "\n".encode('Shift_JIS'), mode: 'wb')

        rows = []
        loader.foreach([csv_path]) { | values | rows << values }

        expect(rows).to eq([%w[A B]])
      end
    end
  end
end

# rubocop:enable RSpec/ExampleLength
