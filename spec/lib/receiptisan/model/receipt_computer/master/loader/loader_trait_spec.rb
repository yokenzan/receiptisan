# frozen_string_literal: true

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
    it 'Shift_JISのCSVを読み込む' do
      Dir.mktmpdir do | dir |
        csv_path = Pathname(dir).join('y_sample.csv')
        csv_path.write('"A","B"' + "\n".encode('Shift_JIS'), mode: 'wb')

        rows = []
        loader.foreach([csv_path]) { | values | rows << values }

        expect(rows).to eq([%w[A B]])
      end
    end

    it 'CRLFを含むShift_JISのCSVを読み込む' do
      Dir.mktmpdir do | dir |
        csv_path = Pathname(dir).join('y_sample.csv')
        csv_path.write("\"A\",\"B\"\r\n".encode('Shift_JIS'), mode: 'wb')

        rows = []
        loader.foreach([csv_path]) { | values | rows << values }

        expect(rows).to eq([%w[A B]])
      end
    end
  end
end
