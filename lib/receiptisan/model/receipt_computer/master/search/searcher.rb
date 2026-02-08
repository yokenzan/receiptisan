# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        module Search
          # Master に対する検索実行
          class Searcher
            # @param master [Master]
            def initialize(master)
              @master = master
            end

            # @param type [Symbol] :shinryou_koui, :iyakuhin, :tokutei_kizai, :comment
            # @param condition [Condition]
            # @return [Array<Treatment::ShinryouKoui, Treatment::Iyakuhin, Treatment::TokuteiKizai, Treatment::Comment>]
            def search(type, condition)
              collection = @master.public_send(type)

              if code_only_condition?(condition)
                item = collection[condition.code.to_sym]
                return item ? [item] : []
              end

              collection.each_value.select { | item | matches?(item, condition) }
            end

            private

            # @param condition [Condition]
            # @return [Boolean]
            def code_only_condition?(condition)
              condition.code && condition.name.nil? && condition.point_exact.nil? &&
                condition.point_min.nil? && condition.point_max.nil?
            end

            def matches?(item, condition)
              matches_code?(item, condition) &&
                matches_name?(item, condition) &&
                matches_point?(item, condition)
            end

            # @param item [Treatment::ShinryouKoui, Treatment::Iyakuhin, Treatment::TokuteiKizai, Treatment::Comment]
            # @param condition [Condition]
            # @return [Boolean]
            def matches_code?(item, condition)
              return true if condition.code.nil?

              item.code.value.to_s == condition.code
            end

            # @param item [Treatment::ShinryouKoui, Treatment::Iyakuhin, Treatment::TokuteiKizai, Treatment::Comment]
            # @param condition [Condition]
            # @return [Boolean]
            def matches_name?(item, condition)
              return true if condition.name.nil?

              targets = name_targets(item)

              case condition.name_match_type
              when :exact
                targets.any? { | t | t == condition.name }
              when :partial
                targets.any? { | t | t.include?(condition.name) }
              end
            end

            # @param item [Treatment::ShinryouKoui, Treatment::Iyakuhin, Treatment::TokuteiKizai, Treatment::Comment]
            # @return [Array<String>]
            def name_targets(item)
              targets = [item.name, item.name_kana]
              targets << item.full_name if item.respond_to?(:full_name)
              targets.compact
            end

            # @param item [Treatment::ShinryouKoui, Treatment::Iyakuhin, Treatment::TokuteiKizai, Treatment::Comment]
            # @param condition [Condition]
            # @return [Boolean]
            def matches_point?(item, condition)
              return true unless point_condition?(condition)

              value = resolve_point_value(item)
              return true if value.nil?

              point_value_in_range?(value, condition)
            end

            # @param condition [Condition]
            # @return [Boolean]
            def point_condition?(condition)
              !condition.point_exact.nil? || !condition.point_min.nil? || !condition.point_max.nil?
            end

            # @param value [Numeric]
            # @param condition [Condition]
            # @return [Boolean]
            def point_value_in_range?(value, condition)
              return false if condition.point_exact && value != condition.point_exact
              return false if condition.point_min && value < condition.point_min
              return false if condition.point_max && value > condition.point_max

              true
            end

            # @param item [Treatment::ShinryouKoui, Treatment::Iyakuhin, Treatment::TokuteiKizai, Treatment::Comment]
            # @return [Numeric, nil]
            def resolve_point_value(item)
              if item.respond_to?(:point)
                item.point
              elsif item.respond_to?(:price)
                item.price
              end
            end
          end
        end
      end
    end
  end
end
