# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    # Recediff CLI application
    class Application
      def initialize
        @commandset = Commandset
        @commandset.register('--show-cost-list',    Command::ShowCostListCommand,   aliases: ['-l'])
        @commandset.register('--show-ef-like-list', Command::ShowEfLikeListCommand, aliases: ['-e'])
        @commandset.register('--preview-uke',       Command::PreviewUkeCommand,     aliases: ['-p'])
        @commandset.register('--version',           Command::ShowVersionCommand,    aliases: ['-v'])
      end

      def run
        Dry::CLI.new(@commandset).call
      end
    end
  end
end
