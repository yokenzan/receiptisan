# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    module Command
      # Command to preview UKE file
      #
      # given arguments and parameters patterns:
      #
      # 1. by giving UKE file path and receipt's sequence
      # 2. by giving UKE file path and receipt's start row index and end row index
      # 3. by giving stdin
      class ReceiptPreviewCommand < Dry::CLI::Command
        argument :uke, required: false
        # 1. by giving UKE file path and receipt's sequence
        option :seqs, type: :string,  requried: false
        # 2. by giving UKE file path and receipt's start row index and end row index
        option :from, type: :integer, requried: false
        option :to,   type: :integer, requried: false

        def initialize
          super
          @parser = Recediff::Parser.create
        end

        # @param [String] uke
        # @param [Hash] options
        def call(uke:, **options)
          receipts =
            case determine_parameter_pattern({ uke: uke }.merge(options))
            when :uke_and_seq
              seqs = parse_seqs(options.fetch(:seqs))
              @parser.parse(uke, seqs.sort.uniq)
            when :uke_and_range
              from = options.fetch(:from)
              to   = options.fetch(:to)
              @parser.parse_area(File.readlines(uke).slice(from.to_i..to.to_i).join)
            when :stdin
              @parser.parse_area($stdin.readlines.join)
            end

          puts receipts
            .map(&:to_preview)
            .join("\n\n=======================================\n\n")
        end

        private

        # @param [Hash] args
        # @return [Symbol]
        def determine_parameter_pattern(args)
          return :stdin unless args.fetch(:uke)

          args.key?(:seqs) ? :uke_and_seq : :uke_and_range
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
      end
    end
  end
end
