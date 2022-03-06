# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    module Command
      # Command to preview UKE file
      class ReceiptPreviewCommand < Dry::CLI::Command
        argument :uke, required: false
        # argument :sequence, requried: true
        option :from, type: :integer, requried: false
        option :to,   type: :integer, requried: false

        def initialize
          super
          @parser = Recediff::Parser.create
        end

        # @param [String] uke
        # @param [Hash] options
        def call(uke:, **options)
          receipt =
            if uke
              from = options.fetch(:from)
              to   = options.fetch(:to)
              @parser.parse_area(File.readlines(uke).slice(from.to_i..to.to_i).join)
            else
              @parser.parse_area($stdin.readlines.join)
            end

          puts receipt.first.to_preview
        end
      end
    end
  end
end
