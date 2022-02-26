# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    # Recediff CLI application
    class Application
      def initialize
        @commandset = Commandset
        @commandset.register('--daily-cost-list', Command::DailyCostListCommand, aliases: ['-l'])
        @commandset.register('--ef-like-csv',     Command::EfLikeCsvCommand,     aliases: ['-e'])
        @commandset.register('--uke-preview',     Command::UkePreviewCommand,    aliases: ['-p'])
        @commandset.register('--version',         Command::VersionCommand,       aliases: ['-v'])
      end

      def run
        Dry::CLI.new(@commandset).call
      end
    end
  end
end
