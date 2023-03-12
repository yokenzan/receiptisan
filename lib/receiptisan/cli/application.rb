# frozen_string_literal: true

require 'dry/cli'

module Receiptisan
  module Cli
    # Receiptisan CLI application
    class Application
      def initialize
        @commandset = Commandset
        @commandset.register('--preview',   Command::PreviewCommand, aliases: ['-p'])
        @commandset.register('--version',   Command::VersionCommand, aliases: ['-v'])
        @commandset.register('--checklist', Command::ReceiptChecklistCommand, aliases: ['-c'])
      end

      def run
        Dry::CLI.new(@commandset).call
      end
    end
  end
end
