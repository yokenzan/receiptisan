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

        CODE_PREFIX_MAP = {
          '1' => :shinryou_koui,
          '6' => :iyakuhin,
          '7' => :tokutei_kizai,
          '8' => :comment,
        }.freeze

        argument :type, required: false, values: TYPE_MAP.keys,
          desc: '検索対象マスター種別 (--code指定時は先頭桁から自動判定)'

        option :code,       desc: 'レセ電コード(完全一致)'
        option :name,       desc: '名称検索(部分一致)'
        option :name_exact, desc: '名称検索(完全一致)'
        option :month,      desc: '検索基準月(YYYYMM形式。省略時は今月)'
        option :point_min,  type: :integer, desc: '点数・価格 下限'
        option :point_max,  type: :integer, desc: '点数・価格 上限'
        option :point,      type: :integer, desc: '点数・価格(完全一致)'
        option :format,     default: 'json', values: %w[json yaml], desc: '出力形式'
        option :limit,      type: :integer, desc: '最大結果件数 (省略時は上限なし)'

        def call(type: nil, **options)
          master_type = resolve_master_type(type, options[:code])
          version     = resolve_version(options[:month])
          master      = load_master(version)
          condition   = build_condition(options)
          results     = Search::Searcher.new(master).search(master_type, condition)
          results     = results.first(options[:limit].to_i) if options[:limit]

          output(results, master_type, options.fetch(:format, 'json'))
        end

        private

        # @param type [String, nil]
        # @param code [String, nil]
        # @return [Symbol]
        def resolve_master_type(type, code)
          if type
            TYPE_MAP.fetch(type)
          elsif code
            CODE_PREFIX_MAP.fetch(code[0]) do
              raise ArgumentError, "コード '#{code}' から種別を判定できません"
            end
          else
            raise ArgumentError, '種別またはコードを指定してください'
          end
        end

        # @param month_str [String, nil]
        # @return [Master::Version]
        def resolve_version(month_str)
          ym = if month_str
                 year  = month_str[0, 4].to_i
                 month = month_str[4, 2].to_i
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
          validate_name_options(options)
          validate_point_options(options)

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

        def validate_name_options(options)
          return unless options[:name] && options[:name_exact]

          raise ArgumentError, '--name と --name-exact は同時に指定できません'
        end

        def validate_point_options(options)
          return unless options[:point] && (options[:point_min] || options[:point_max])

          warn '--point と --point-min/--point-max が同時に指定されました。--point を優先します'
          options.delete(:point_min)
          options.delete(:point_max)
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
