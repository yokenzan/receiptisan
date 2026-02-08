# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        module Search
          # 検索条件の値オブジェクト
          class Condition
            # @param code [String, nil] レセ電コード (完全一致)
            # @param name [String, nil] 名称検索文字列
            # @param name_match_type [Symbol] :partial (部分一致) or :exact (完全一致)
            # @param point_min [Numeric, nil] 点数/価格 下限
            # @param point_max [Numeric, nil] 点数/価格 上限
            # @param point_exact [Numeric, nil] 点数/価格 完全一致
            def initialize(
              code: nil,
              name: nil,
              name_match_type: :partial,
              point_min: nil,
              point_max: nil,
              point_exact: nil
            )
              @code            = code
              @name            = name
              @name_match_type = name_match_type
              @point_min       = point_min
              @point_max       = point_max
              @point_exact     = point_exact
            end

            # @!attribute [r] code
            #   @return [String, nil]
            # @!attribute [r] name
            #   @return [String, nil]
            # @!attribute [r] name_match_type
            #   @return [Symbol]
            # @!attribute [r] point_min
            #   @return [Numeric, nil]
            # @!attribute [r] point_max
            #   @return [Numeric, nil]
            # @!attribute [r] point_exact
            #   @return [Numeric, nil]
            attr_reader :code, :name, :name_match_type, :point_min, :point_max, :point_exact
          end
        end
      end
    end
  end
end
