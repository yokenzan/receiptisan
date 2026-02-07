# frozen_string_literal: true

require 'logger'
require 'month'
require 'json'
require 'yaml'

module Receiptisan
  module Cli
    module Command
      # マスターデータ検索コマンド
      class SearchCommand < Dry::CLI::Command
        Master  = Receiptisan::Model::ReceiptComputer::Master
        Search  = Master::Search

        TYPE_MAP = {
          'shinryou-koui' => :shinryou_koui,
          'iyakuhin' => :iyakuhin,
          'tokutei-kizai' => :tokutei_kizai,
          'comment' => :comment,
        }.freeze

        argument :type, required: true, values: TYPE_MAP.keys,
          desc: '検索対象マスター種別'

        option :code,       desc: 'レセ電コード (完全一致)'
        option :name,       desc: '名称検索 (部分一致)'
        option :name_exact, desc: '名称検索 (完全一致)'
        option :month,      desc: '基準月 (YYYY-MM形式, 省略時は今月)'
        option :point_min,  type: :integer, desc: '点数/価格 下限'
        option :point_max,  type: :integer, desc: '点数/価格 上限'
        option :point,      type: :integer, desc: '点数/価格 (完全一致)'
        option :format,     default: 'json', values: %w[json yaml], desc: '出力形式'
        option :limit,      type: :integer, default: 100, desc: '最大結果件数'

        def call(type:, **options)
          master_type = TYPE_MAP.fetch(type)
          version     = resolve_version(options[:month])
          master      = load_master(version)
          condition   = build_condition(options)
          results     = Search::Searcher.new(master).search(master_type, condition)
          results     = results.first(options.fetch(:limit, 100).to_i)

          output(results, master_type, options.fetch(:format, 'json'))
        end

        private

        # @param month_str [String, nil]
        # @return [Master::Version]
        def resolve_version(month_str)
          ym = if month_str
                 year, month = month_str.split('-').map(&:to_i)
                 Month.new(year, month)
               else
                 Month.new(Date.today.year, Date.today.month)
               end

          Master::Version.resolve_by_ym(ym) or
            raise ArgumentError, "指定月 #{ym} に対応するマスターバージョンが見つかりません"
        end

        # @param version [Master::Version]
        # @return [Master]
        def load_master(version)
          logger = Logger.new($stderr, level: Logger::WARN)
          loader = Master::Loader.new(Master::ResourceResolver.new, logger)
          loader.load(version)
        end

        # @param options [Hash]
        # @return [Search::Condition]
        def build_condition(options)
          name = options[:name_exact] || options[:name]
          name_match_type = options[:name_exact] ? :exact : :partial

          Search::Condition.new(
            code:            options[:code],
            name:            name,
            name_match_type: name_match_type,
            point_min:       to_integer(options[:point_min]),
            point_max:       to_integer(options[:point_max]),
            point_exact:     to_integer(options[:point])
          )
        end

        # @param value [String, Integer, nil]
        # @return [Integer, nil]
        def to_integer(value)
          value&.to_i
        end

        # @param results [Array]
        # @param type [Symbol]
        # @param format [String]
        def output(results, type, format)
          data = results.map { | item | item_to_hash(item, type) }

          case format
          when 'json'
            puts JSON.pretty_generate(data)
          when 'yaml'
            puts YAML.dump(data)
          end
        end

        # @param item [Master::Treatment::ShinryouKoui, Master::Treatment::Iyakuhin, Master::Treatment::TokuteiKizai, Master::Treatment::Comment]
        # @param type [Symbol]
        # @return [Hash]
        def item_to_hash(item, type)
          hash = {
            'code' => item.code.value.to_s,
            'name' => item.name,
            'name_kana' => item.name_kana,
          }

          hash['full_name'] = item.full_name if item.respond_to?(:full_name)

          case type
          when :shinryou_koui
            hash['point_type'] = item.point_type&.name
            hash['point']      = item.point
            hash['unit']       = item.unit&.name
          when :iyakuhin, :tokutei_kizai
            hash['price'] = item.price
            hash['unit']  = item.unit&.name
          end

          hash
        end
      end
    end
  end
end
