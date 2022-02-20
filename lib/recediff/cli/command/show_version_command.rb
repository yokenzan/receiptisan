# frozen_string_literal: true

module Recediff
  module Cli
    module Command
      # Command to show version and exit
      class ShowVersionCommand < Dry::CLI::Command
        def call
          puts Recediff::VERSION
        end
      end
    end
  end
end
