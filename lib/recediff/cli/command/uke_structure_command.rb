# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    module Command
      # Command to parse structure of UKE file
      class UkeStructureCommand < Dry::CLI::Command
        argument :uke, required: false

        # @param [String?] uke
        def call(uke: nil, **_options)
          puts Recediff::SummaryParser.new.parse_as_receipt_summaries(uke)
        end
      end
    end
  end
end
