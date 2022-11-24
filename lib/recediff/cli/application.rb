# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    # Recediff CLI application
    class Application
      def initialize
        @commandset = Commandset
        @commandset.register('--preview', Command::PreviewCommand, aliases: ['-p'])
        @commandset.register('--version', Command::VersionCommand, aliases: ['-v'])
      end

      def run
        Dry::CLI.new(@commandset).call
      end
    end
  end
end
