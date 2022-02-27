# frozen_string_literal: true

require 'stringio'
require 'recediff'

RSpec.describe Recediff::Cli::Command::DailyCostListCommand do
  # @type [Recediff::Cli::Command::DailyCostListCommand] command
  let(:klass)   { Recediff::Cli::Command::DailyCostListCommand }
  let(:command) { klass.new }

  describe 'parses UKE and outputs daily cost list' do
    it 'requires named argument :uke' do
      expect { command.call({}) }.to raise_error(ArgumentError)
    end

    it 'throws Errno::ENOENT if given :uke does not exist' do
      uke     = 'file/which/does/not/exist'
      message = /No such file or directory/
      expect { command.call(uke: uke) }.to raise_error(Errno::ENOENT, message)
    end

    it 'parses UKE file and outputs daily cost list' do
      uke       = 'spec/resource/input/RECEIPTC_GAIRAI_SAMPLE.UKE'
      content   = File.read('spec/resource/output/gairai_cost_list.txt')

      toward_stringio do | stdout |
        command.call(uke: uke)
        expect(stdout.string).to eq content
      end
    end
  end
end
