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
              seqs = []
              options.fetch(:seqs).scan(/(\d+)(-\d+)?,?/) do | a, b |
                seqs << (b.nil? ? a.to_i : ((a.to_i)..(b.to_i.abs)).to_a)
              end
              @parser.parse(uke, seqs.flatten.sort.uniq)
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
      end
    end
  end
end
