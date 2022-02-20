# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    module Command
      # Command to preview UKE file
      class PreviewUkeCommand < Dry::CLI::Command
        argument :uke_text, required: false

        def initialize
          super
          @parser = Recediff::Parser.new(
            Recediff::Master.load('./csv'),
            Recediff::DiseaseMaster.load('./csv'),
            Recediff::ShushokugoMaster.load('./csv'),
            Recediff::CommentMaster.load('./csv')
          )
        end

        # @param [String?] uke_text
        def call(uke_text: nil)
          puts @parser
            .parse_area(uke_text || $stdin.readlines.join)
            .map(&:to_preview)
            .join("\n\n=======================================\n\n")
        end
      end
    end
  end
end
