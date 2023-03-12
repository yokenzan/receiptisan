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
      class ReceiptChecklistCommand < Dry::CLI::Command
        include Receiptisan::Model::ReceiptComputer

        Parser  = DigitalizedReceipt::Parser
        Options = Parser::SupplementalOptions

        argument :uke_file_paths, required: false, type: :array, desc: 'paths of RECEIPTC.UKE files to create checklist'
        # hospitals
        option :hospitals, type: :json, desc: 'parameters for hospitals(each hospital has location, code, bed_count)'

        # check rules
        option :check_naifuku_tazai, type: :boolean, desc: '内服他剤投与に該当する可能性があるが他剤投与逓減が適用されていないレセプトを抽出します'
        option :check_cholesterol, type: :boolean, desc: 'Tcho, LDL-コレステロール, HDL-コレステロールを併算定しているレセプトを抽出します'
        option :check_influenza, type: :boolean, desc: 'インフルエンザウイルス抗原訂正, Sars-Cov-2抗原検出, 抗原同時検出を併算定しているレセプトを抽出します'
        option :check_sm, type: :boolean, desc: 'Ｓ−Ｍ, Ｓ−蛍光Ｍ、位相差Ｍ、暗視野Ｍを併算定しているレセプトを抽出します'
        option :check_es_xylocaine, type: :boolean, desc: '内視鏡検査でキシロカインゼリーを使用しているレセプトを抽出します'
        option :check_yakujou, type: :boolean, desc: '薬剤情報提供料を月に2回以上算定しているレセプトを抽出します'
        option :check_dimethicone, type: :boolean, desc: 'ジメチコンを使用しているが胃カメラを実施していないレセプトを抽出します'

        # @param [Array<String>] uke_file_paths
        # @param [Hash] options
        def call(uke_file_paths: [], **options)
          initialize_parser
          initialize_check_rules(options)

          digitalized_receipts = parse(uke_file_paths, options)
          checklist            = check(digitalized_receipts)

          puts checklist
        end

        private

        def initialize_parser
          @parser = DigitalizedReceipt::Parser.new(
            DigitalizedReceipt::Parser::MasterHandler.new(Master::Loader.new(Master::ResourceResolver.new)),
            Logger.new($stderr)
          )
        end

        def initialize_check_rules(options)
          @check_executor = Reporting::ReceiptCheckExecutor.new

          options[:check_cholesterol]   && @check_executor.add_rule(Reporting::Rule::CholesterolRule.new)
          options[:check_dimethicone]   && @check_executor.add_rule(Reporting::Rule::DimethiconeRule.new)
          options[:check_es_xylocaine]  && @check_executor.add_rule(Reporting::Rule::ESWithXylocaineRule.new)
          options[:check_influenza]     && @check_executor.add_rule(Reporting::Rule::InfluenzaRule.new)
          options[:check_naifuku_tazai] && @check_executor.add_rule(Reporting::Rule::NaifukuTazaiRule.new)
          options[:check_sm]            && @check_executor.add_rule(Reporting::Rule::SMRule.new)
          options[:check_yakujou]       && @check_executor.add_rule(Reporting::Rule::YakujouRule.new)

          raise unless @check_executor.any_rules?
        end

        # @param uke_file_paths [Array<String>]
        # @return [Array<Model::ReceiptComputer::DigitalizedReceipt>]
        def parse(uke_file_paths, options)
          supplemental_options = Options.from(options[:hospitals])
          parse_proc           = proc { | io | @parser.parse(io, supplemental_options) }

          (uke_file_paths.empty? ?
            parse_proc.call($stdin) :
            uke_file_paths.map { | path | File.open(path) { | io | parse_proc.call(io) } }).flatten
        end

        def check(digitalized_receipts)
          digitalized_receipts.map { | digitalized_receipt | @check_executor.check(digitalized_receipt) }.flatten
        end
      end
    end
  end
end
