# frozen_string_literal: true

require 'logger'
require 'dry/cli'

module Receiptisan
  module Cli
    module Command
      # Command to view RECEIPTC.UKE files in TUI
      class ViewCommand < Dry::CLI::Command
        include Receiptisan::Model::ReceiptComputer

        Parser = DigitalizedReceipt::Parser

        argument :uke_file_path, required: true, desc: 'path of RECEIPTC.UKE file to view'

        # @param uke_file_path [String]
        def call(uke_file_path:, **)
          initialize_parser
          digitalized_receipts = parse(uke_file_path)
          Receiptisan::Tui::Application.new(digitalized_receipts).run
        end

        private

        def initialize_parser
          logger = Logger.new($stderr, level: Logger::WARN)

          @parser = DigitalizedReceipt::Parser.new(
            DigitalizedReceipt::Parser::MasterHandler.new(
              Master::Loader.new(
                Master::ResourceResolver.new,
                logger
              )
            ),
            logger
          )
        end

        # @param uke_file_path [String]
        # @return [Array<Model::ReceiptComputer::DigitalizedReceipt>]
        def parse(uke_file_path)
          options = Parser::SupplementalOptions.from(nil)
          File.open(uke_file_path) { | io | @parser.parse(io, options) }
        end
      end
    end
  end
end
