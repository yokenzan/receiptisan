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

        argument :uke, required: false
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
        # config for previewer selection
        option :format, default: 'cli', values: %w[cli svg yaml json], desc: 'preview format'

        # @param [String] uke
        # @param [Hash] options
        def call(uke: nil, **options)
          _parameter_pattern  = determine_parameter_pattern({ uke: uke }.merge(options))
          @previewer          = determine_previewer(options[:format])
          digitalized_receipt = parse(uke)
          preview_receipts(digitalized_receipt)
        end

        private

        # @param [Hash] args
        # @return [Symbol]
        def determine_parameter_pattern(args)
          return :stdin unless args.fetch(:uke)
          return :uke_all if args[:all]

          args.key?(:seqs) ? :uke_and_seq : :uke_and_range
        end

        # @return [#preview]
        def determine_previewer(format)
          case format.downcase
          when 'svg'
            Preview::Previewer::SVGPreviewer.new
          when 'json'
            Preview::Previewer::JSONPreviewer.new
          when 'yaml'
            Preview::Previewer::YAMLPreviewer.new
          else
            raise ArgumentError, "unsupported preview format specified : '#{format}'"
          end
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

        def preview_receipts(digitalized_receipt)
          puts @previewer.preview(Preview::Parameter::Generator.create.convert_digitalized_receipt(digitalized_receipt))
        end
      end
    end
  end
end
