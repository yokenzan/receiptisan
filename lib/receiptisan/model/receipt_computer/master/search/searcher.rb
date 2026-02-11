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
              @name_exact_indexes = {}
              @point_exact_indexes = {}
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

              candidates = search_candidates(type, collection, condition)
              candidates.select { | item | matches?(item, condition) }
            end

            private

            # @param type [Symbol]
            # @param collection [Hash]
            # @param condition [Condition]
            # @return [Array, Enumerable]
            def search_candidates(type, collection, condition)
              return collection.each_value unless indexed_candidate_condition?(condition)

              name_candidates = name_exact_candidates(type, collection, condition)
              point_candidates = point_exact_candidates(type, collection, condition)

              merge_candidates(name_candidates, point_candidates, collection)
            end

            # @param condition [Condition]
            # @return [Boolean]
            def indexed_candidate_condition?(condition)
              name_exact_condition?(condition) || point_exact_condition?(condition)
            end

            # @param condition [Condition]
            # @return [Boolean]
            def name_exact_condition?(condition)
              condition.name && condition.name_match_type == :exact
            end

            # @param condition [Condition]
            # @return [Boolean]
            def point_exact_condition?(condition)
              !condition.point_exact.nil?
            end

            # @param collection [Hash]
            # @param condition [Condition]
            # @return [Boolean]
            def point_exact_index_available?(collection, condition)
              point_exact_condition?(condition) && point_searchable_collection?(collection)
            end

            # @param type [Symbol]
            # @param collection [Hash]
            # @param condition [Condition]
            # @return [Array, nil]
            def name_exact_candidates(type, collection, condition)
              return nil unless name_exact_condition?(condition)

              name_exact_index(type, collection).fetch(condition.name, [])
            end

            # @param type [Symbol]
            # @param collection [Hash]
            # @param condition [Condition]
            # @return [Array, nil]
            def point_exact_candidates(type, collection, condition)
              return nil unless point_exact_index_available?(collection, condition)

              point_exact_index(type, collection).fetch(condition.point_exact, [])
            end

            # @param name_candidates [Array, nil]
            # @param point_candidates [Array, nil]
            # @param collection [Hash]
            # @return [Array, Enumerable]
            def merge_candidates(name_candidates, point_candidates, collection)
              return name_candidates & point_candidates if name_candidates && point_candidates

              name_candidates || point_candidates || collection.each_value
            end

            # @param type [Symbol]
            # @param collection [Hash]
            # @return [Hash<String, Array>]
            def name_exact_index(type, collection)
              @name_exact_indexes[type] ||= build_name_exact_index(collection)
            end

            # @param collection [Hash]
            # @return [Hash<String, Array>]
            def build_name_exact_index(collection)
              Hash.new { | hash, key | hash[key] = [] }.tap do | index |
                collection.each_value do | item |
                  name_targets(item).each do | target |
                    index[target] << item unless index[target].include?(item)
                  end
                end
              end
            end

            # @param type [Symbol]
            # @param collection [Hash]
            # @return [Hash<Numeric, Array>]
            def point_exact_index(type, collection)
              @point_exact_indexes[type] ||= build_point_exact_index(collection)
            end

            # @param collection [Hash]
            # @return [Hash<Numeric, Array>]
            def build_point_exact_index(collection)
              Hash.new { | hash, key | hash[key] = [] }.tap do | index |
                collection.each_value do | item |
                  value = resolve_point_value(item)
                  next if value.nil?

                  index[value] << item
                end
              end
            end

            # @param collection [Hash]
            # @return [Boolean]
            def point_searchable_collection?(collection)
              first = collection.each_value.first
              return false unless first

              first.respond_to?(:point) || first.respond_to?(:price)
            end

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
