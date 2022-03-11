# frozen_string_literal: true

require 'stringio'
require 'recediff'

RSpec.describe Recediff::Cli::Command::ReceiptPreviewCommand do
  # @type [Recediff::Cli::Command::ReceiptPreviewCommand] command
  let(:klass)   { Recediff::Cli::Command::ReceiptPreviewCommand }
  let(:command) { klass.new }
  let(:uke)     { 'file/which/does/not/exist' }

  describe 'parses UKE and outputs receipt preview' do
    it 'throws Errno::ENOENT if given :uke does not exist' do
      options = { from: 0, to: 1 }
      message = /No such file or directory/
      expect { command.call(uke: uke, **options) }.to raise_error(Errno::ENOENT, message)
    end

    it 'throws KeyError if options which have keys :from and :to not given' do
      options = {}
      expect { command.call(uke: uke, **options) }.to raise_error(KeyError)
    end

    it 'throws KeyError if options not given' do
      expect { command.call(uke: uke) }.to raise_error(KeyError)
    end

    it 'get receipt preview by giving uke-path and line range' do
      # seq: 9
      options = { from: 89, to: 99 }
      ukefile = 'spec/resource/input/RECEIPTC_GAIRAI_SAMPLE.UKE'
      content = File.read('spec/resource/output/gairai_receipt_preview.txt')

      toward_stringio do | stdout |
        command.call(uke: ukefile, **options)
        expect(stdout.string).to eq content
      end
    end

    it 'get receipt preview by giving receipt preview via stdin' do
      # seq: 9
      input   = File.read('spec/resource/input/receipt_gairai_sample.txt')
      content = File.read('spec/resource/output/gairai_receipt_preview.txt')

      toward_stringio do | stdout |
        $stdin = StringIO.new(input)
        command.call(uke: nil)
        expect(stdout.string).to eq content
      end
    end

    it 'get receipt preview by giving uke-path and receipt seq' do
      # seq: 9
      options = { seqs: '9' }
      ukefile = 'spec/resource/input/RECEIPTC_GAIRAI_SAMPLE.UKE'
      content = File.read('spec/resource/output/gairai_receipt_preview.txt')

      toward_stringio do | stdout |
        command.call(uke: ukefile, **options)
        expect(stdout.string).to eq content
      end
    end
  end
end
