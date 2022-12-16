# frozen_string_literal: true

require 'logger'
require 'dry/cli'

module Receiptisan
  module Cli
    module Command
      # Command to preview UKE file
      #
      # given arguments and parameters patterns:
      #
      # 1. by giving UKE file path and receipt's sequence
      # 2. by giving UKE file path and receipt's start row index and end row index
      # 3. by giving stdin
      class PreviewCommand < Dry::CLI::Command
        include Receiptisan::Model::ReceiptComputer

        Preview = Receiptisan::Output::Preview

        argument :uke_file_paths, required: false, type: :array, desc: 'paths of UKE files to preview'

        # 1. by giving UKE file path and receipt's sequence
        option :seqs,  type: :string,  requried: false
        option :all,   type: :boolean, requried: false
        # 2. by giving UKE file path and receipt's start row index and end row index
        option :from,  type: :integer, requried: false
        option :to,    type: :integer, requried: false
        # config for color highlighting
        option :color,    type: :boolean, requried: false, default: false
        # config for previewing
        option :calcunit, type: :boolean, required: false, default: true
        option :header,   type: :boolean, required: false, default: true
        option :hoken,    type: :boolean, required: false, default: true
        option :disease,  type: :boolean, required: false, default: true
        option :mask,     type: :boolean, required: false, default: false
        # config for preview format
        option :format, default: 'cli', values: %w[cli svg yaml json], desc: 'preview format'

        # @param [Array<String>] uke
        # @param [Hash] options
        def call(uke_file_paths: [], **options)
          abort 'no files given.' if uke_file_paths.empty?

          determine_previewer(options[:format])

          digitalized_receipt_parameters = uke_file_paths.each_with_object([]) do | uke_file_path, carry |
            carry << build_preview_parameter(parse(uke_file_path))
          end

          show_preview(*digitalized_receipt_parameters)
        end

        private

        # @param [Hash] args
        # @return [Symbol]
        def determine_parameter_pattern(args)
          return :stdin unless args.fetch(:uke)
          return :uke_all if args[:all]

          args.key?(:seqs) ? :uke_and_seq : :uke_and_range
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

        # @param [String] text_seqs
        # @return [Array<Integer>]
        def parse_seqs(text_seqs)
          [].tap do | seqs |
            text_seqs.scan(/(\d+)(-\d+)?,?/) do | f, t |
              seqs.concat(t.nil? ? [f.to_i] : ((f.to_i)..(t.to_i.abs)).to_a)
            end
          end
        end

        def parse(uke)
          parser = DigitalizedReceipt::Parser.new(
            DigitalizedReceipt::Parser::MasterHandler.new(Master::Loader.new(Master::ResourceResolver.new)),
            Logger.new($stderr)
          )
          parser.parse(uke)
        end

        def __(parameter_pattern, options)
          case parameter_pattern
          when :uke_all
            parser.parse(uke)
          when :uke_and_seq
            seqs = parse_seqs(options.fetch(:seqs))
            parser.parse(uke, seqs.sort.uniq)
          when :uke_and_range
            from = options[:from]
            to   = options[:to]
            parser.parse_area(
              File.readlines(uke)
                .slice(from && to ? from.to_i..to.to_i : from.to_i..)
                .join
            )
          when :stdin
            parser.parse_area($stdin.readlines.join)
          end
        end

        # @param digitalized_receipt [Array<Model::ReceiptComputer::DigitalizedReceipt>]
        def build_preview_parameter(digitalized_receipt)
          Preview::Parameter::Generator.create.convert_digitalized_receipt(digitalized_receipt)
        end

        # @param digitalized_receipt [Model::ReceiptComputer::DigitalizedReceipt]
        def show_preview(*digitalized_receipts)
          puts @previewer.preview(*digitalized_receipts)
        end
      end
    end
  end
end
