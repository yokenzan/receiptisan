# frozen_string_literal: true

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
        option :mode, default: 'cli', values: %w[cli svg], desc: 'preview method'

        # @param [String] uke
        # @param [Hash] options
        def call(uke: nil, **options)
          parameter_pattern = determine_parameter_pattern({ uke: uke }.merge(options))
          receipts          = parse_uke(parameter_pattern, uke, options)
          @previewer        = determine_previewer(options)
          preview_receipts(receipts)
        end

        private

        # @param [Hash] args
        # @return [Symbol]
        def determine_parameter_pattern(args)
          return :stdin unless args.fetch(:uke)
          return :uke_all if args[:all]

          args.key?(:seqs) ? :uke_and_seq : :uke_and_range
        end

        def determine_previewer(options)
          case options[:mode]
          when 'cli'
            Receiptisan::Previewer.new(options)
          when 'svg'
            Receiptisan::Previewer.new(options)
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

        def parse_uke(parameter_pattern, uke, options)
          parser = Receiptisan::Parser.create

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

        def preview_receipts(receipts)
          @previewer.preview(receipts)
        end
      end
    end
  end
end
