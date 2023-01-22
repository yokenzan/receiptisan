# frozen_string_literal: true

require 'logger'
require 'dry/cli'

module Receiptisan
  module Cli
    module Command
      # Command to preview RECEIPTC.UKE files
      #
      # given arguments and parameters patterns:
      #
      # 1. by giving UKE file paths
      # 2. by giving stdin
      class PreviewCommand < Dry::CLI::Command
        include Receiptisan::Model::ReceiptComputer

        Preview = Receiptisan::Output::Preview
        Parser  = DigitalizedReceipt::Parser

        argument :uke_file_paths, required: false, type: :array, desc: 'paths of RECEIPTC.UKE files to preview'

        # config for preview format
        option :format, default: 'svg', values: %w[svg yaml json], desc: 'preview format'

        # @param [Array<String>] uke_file_paths
        # @param [Hash] options
        def call(uke_file_paths: [], **options)
          initialize_parser
          initialize_preview_parameter_generator
          determine_previewer(options[:format])

          digitalized_receipts = parse(uke_file_paths)
          parameters           = to_preview_parameters(digitalized_receipts)
          show_preview(parameters)
        end

        private

        def initialize_parser
          @parser = DigitalizedReceipt::Parser.new(
            DigitalizedReceipt::Parser::MasterHandler.new(Master::Loader.new(Master::ResourceResolver.new)),
            Logger.new($stderr)
          )
        end

        def determine_previewer(format)
          @previewer = \
            case format.downcase
            when 'svg'
              Preview::Previewer::SVGPreviewer.new
            when 'json'
              Preview::Previewer::JSONPreviewer.new
            when 'yaml'
              Preview::Previewer::YAMLPreviewer.new
            end

          @previewer or raise ArgumentError, "unsupported preview format specified : '#{format}'"
        end

        def initialize_preview_parameter_generator
          @generator = Preview::Parameter::Generator.create
        end

        # @param uke_file_paths [Array<String>]
        # @return [Array<Model::ReceiptComputer::DigitalizedReceipt>]
        def parse(uke_file_paths)
          parse_proc = proc { | io | @parser.parse(io) }

          (uke_file_paths.empty? ?
            parse_proc.call($stdin) :
            uke_file_paths.map { | path | File.open(path) { | io | parse_proc.call(io) } }).flatten
        end

        # @return [Array<Output::Preview::Parameter::Common::DigitalizedReceipt>]
        def to_preview_parameters(digitalized_receipts)
          digitalized_receipts.map do | digitalized_receipt |
            @generator.convert_digitalized_receipt(digitalized_receipt)
          end
        end

        # @param digitalized_receipt_parameters [Array<Output::Preview::Parameter::Common::DigitalizedReceipt>]
        def show_preview(digitalized_receipt_parameters)
          puts @previewer.preview(*digitalized_receipt_parameters)
        end
      end
    end
  end
end
