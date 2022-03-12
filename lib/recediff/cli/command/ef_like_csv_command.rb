# frozen_string_literal: true

module Recediff
  module Cli
    module Command
      # Command to show EF file like cost list
      class EfLikeCsvCommand < Dry::CLI::Command
        argument :uke, required: true

        # @param [String?] uke
        def call(uke:, **_options)
          puts Recediff::Parser.create.parse(uke).map(&:to_csv)
        end
      end
    end
  end
end
