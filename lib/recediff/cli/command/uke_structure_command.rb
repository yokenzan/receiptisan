# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    module Command
      # Command to parse structure of UKE file
      class UkeStructureCommand < Dry::CLI::Command
        argument :uke, required: false

        def initialize
          super
          @parser = Recediff::SummaryParser.new
        end

        # @param [String?] uke
        def call(uke: nil, **_options)
          puts @parser.parse_as_uke_receipts(uke)
        end
      end
    end
  end
end
