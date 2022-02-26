# frozen_string_literal: true

module Recediff
  module Cli
    module Command
      # Command to show EF file like cost list
      class ShowEfLikeListCommand < Dry::CLI::Command
        argument :uke, required: false

        def initialize
          super
          @parser = Recediff::Parser.create
        end

        # @param [String?] uke
        def call(uke: nil, **_options)
          receipts_in_uke = @parser.parse(uke)

          puts receipts_in_uke.map(&:to_csv)
        end
      end
    end
  end
end
