# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    module Command
      # Command to preview UKE file
      class ShowCostListCommand < Dry::CLI::Command
        argument :uke, required: true
        option :sum,   type: :boolean, default: false
        option :count, type: :boolean, default: false

        def initialize
          super
          @parser = Recediff::Parser.create
        end

        # @param [String] name
        # @param [Hash] options
        def call(uke:, **options)
          receipts_in_uke = @parser.parse(uke)

          puts receipts_in_uke.map(&:show)

          puts receipts_in_uke.sum(&:point) if options.fetch(:sum)
          puts receipts_in_uke.length       if options.fetch(:count)
        end
      end
    end
  end
end
