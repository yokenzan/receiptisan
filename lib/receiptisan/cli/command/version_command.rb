# frozen_string_literal: true

module Receiptisan
  module Cli
    module Command
      # Command to show version and exit
      class VersionCommand < Dry::CLI::Command
        def call
          puts Receiptisan::VERSION
        end
      end
    end
  end
end
