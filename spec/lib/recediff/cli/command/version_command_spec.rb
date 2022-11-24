# frozen_string_literal: true

require 'stringio'
require 'recediff'

RSpec.describe Recediff::Cli::Command::VersionCommand do
  # @type [Recediff::Cli::Command::VersionCommand] command
  let(:klass)   { described_class }
  let(:command) { klass.new }

  describe "shows gem's version" do
    it "shows gem's version with no argument" do
      toward_stringio do | stdout |
        command.call
        expect(stdout.string).to match Recediff::VERSION
      end
    end
  end
end
