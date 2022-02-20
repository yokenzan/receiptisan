# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    # Recediff CLI application
    class Application
      def initialize
        @commandset = Commandset
        @commandset.register('--preview-uke',    Command::PreviewUkeCommand,   aliases: ['-p'])
        @commandset.register('--version',        Command::ShowVersionCommand,  aliases: ['-v'])
        @commandset.register('--show-cost-list', Command::ShowCostListCommand, aliases: ['-l'])
      end

      def run
        Dry::CLI.new(@commandset).call
      end
    end
  end
end
