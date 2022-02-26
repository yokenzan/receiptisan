# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    module Command
      # Command to preview UKE file
      class PreviewUkeCommand < Dry::CLI::Command
        argument :uke, required: false

        def initialize
          super
          @parser = Recediff::Parser.create
        end

        # @param [String?] uke_text
        def call(uke: nil, **_options)
          previewed_receipts =
            if uke
              @parser.parse(uke)
            else
              @parser.parse_area($stdin.readlines.join)
            end

          puts previewed_receipts
            .map(&:to_preview)
            .join("\n\n=======================================\n\n")
        end
      end
    end
  end
end
