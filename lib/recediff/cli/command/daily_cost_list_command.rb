# frozen_string_literal: true

require 'dry/cli'

module Recediff
  module Cli
    module Command
      # Command to preview UKE file
      class DailyCostListCommand < Dry::CLI::Command
        argument :uke, required: true
        option :sum,    type: :boolean, default: false
        option :count,  type: :boolean, default: false
        option :header, type: :boolean, default: false

        # @param [String] name
        # @param [Hash] options
        def call(uke:, **options)
          receipts_in_uke = Recediff::Parser.create.parse(uke)

          puts headers.join("\t") if options.key(:header) && options.fetch(:header)
          puts receipts_in_uke.map(&:show)

          puts receipts_in_uke.sum(&:point) if options.key?(:sum)   && options.fetch(:sum)
          puts receipts_in_uke.length       if options.key?(:count) && options.fetch(:count)
        end
      end

      def headers
        %w(
          レコード識別
          レセプト番号
          患者番号
          氏名
          傷病コード
          傷病名
          開始日
          転帰
          診療日
          算定単位の診療識別
          コスト種別
          idx
          レセ電コード
          コスト名称
          数量
          点数
          回数
        )
      end
    end
  end
end
