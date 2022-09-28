# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    module Command
      # Command to preview UKE file
      class SokatsuCommand < Dry::CLI::Command
        argument :uke, required: true

        # @param [String] name
        # @param [Hash] options
        def call(uke:, **options)
          receipts_in_uke = Recediff::Parser.create.parse(uke)
          csv             = receipts_in_uke.map do | r |
            receipt_columns = [
              r.shinryo_ym,
              r.shaho_or_kokuho,
              r.type.to_s,
              r.type.shuhoken_type_code       + r.type.shuhoken_type,
              r.type.hoken_multiple_type_code + r.type.hoken_multiple_type,
              r.type.age_type_code            + r.type.age_type,
              r.type.hoken_multiple_type.include?('併') ? '併用' : '単独',
            ]

            r.hokens.map do | h |
              receipt_columns +
                case h
                when Recediff::Iho
                  [
                    'HO',
                    sprintf('%08d', h.hokenja_bango.to_i)[2, 2],
                    h.hokenja_bango,
                    h.day_count,
                    h.point,
                    h.futankin,
                  ]
                when Recediff::Kohi
                  [
                    'KO',
                    sprintf('%08d', h.futansha_bango.to_i)[2, 2],
                    h.futansha_bango,
                    h.day_count,
                    h.point,
                    h.futankin,
                  ]
                end
            end
          end


          headers = %w(
              診療年月
              社保国保
              レセプト種別
              レセプト主保険種別
              レセプト保険種別
              レセプト年齢種別
              レセプト単独併用
          ) + %w(
              保険ヘッダ
              法別
              保険者番号/負担者番号
              実日数
              点数
              負担金
          )

          delimiter = ','
        puts headers.join(delimiter)
        puts csv.flatten(1).map { | row | row.join(delimiter) }
      end
    end
  end
end
end
