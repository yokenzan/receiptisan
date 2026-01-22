# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            # 点数・回数算定単位
            class SanteiUnit
              extend Forwardable

              def initialize
                # @type tensuu [Integer, nil]
                @tensuu        = nil
                # @type kaisuu [Integer, nil]
                @kaisuu        = nil
                # @type tekiyou_items [Array<Cost, Comment>]
                @tekiyou_items = []
                @daily_kaisuus = []
              end

              # @param tekiyou_item [Cost, Comment]
              # @return [void]
              def add_tekiyou(tekiyou_item)
                tekiyou_items << tekiyou_item
              end

              # @return [void]
              def fix!
                bottom_cost = tekiyou_items.reverse.find(&:tensuu?)
                return unless bottom_cost

                @tensuu        = bottom_cost.tensuu
                @kaisuu        = bottom_cost.kaisuu
                @daily_kaisuus = bottom_cost.daily_kaisuus
              end

              # @return [Symbol, nil] returns nil when only costists of comments.
              def resource_type
                tekiyou_items.find { | tekiyou_item | !tekiyou_item.comment? }&.resource_type
              end

              def each_cost(&)
                enum = tekiyou_items.reject(&:comment?).enum_for(:each)

                block_given? ? enum.each(&) : enum
              end

              # @return [Enumnerator]
              def each_date
                Enumerator.new { | y | @daily_kaisuus.each { | it | y << it } }
              end

              def on_date?(date)
                @daily_kaisuus.any? { | daily_kaisuu | daily_kaisuu.on?(date) }
              end

              # @return [self, nil]
              def on_date(date)
                daily_kaisuu = @daily_kaisuus.find { | dk | dk.on?(date) }

                return nil unless daily_kaisuu

                new_unit = self.class.new

                tekiyou_items.each do | cost_or_comment |
                  if cost_or_comment.comment?
                    new_unit.add_tekiyou(cost_or_comment)
                  else
                    cost = cost_or_comment
                    new_cost = Cost.new(
                      resource:            cost.resource,
                      shinryou_shikibetsu: cost.shinryou_shikibetsu,
                      futan_kubun:         cost.futan_kubun,
                      tensuu:              cost.tensuu,
                      kaisuu:              daily_kaisuu.kaisuu,
                      daily_kaisuus:       [daily_kaisuu]
                    )
                    cost.each_comment { | c | new_cost.add_comment(c) }

                    new_unit.add_tekiyou(new_cost)
                  end
                end

                new_unit.fix!
                new_unit
              end

              # @return [Integer, nil]
              def calculate
                tensuu && kaisuu ? tensuu * kaisuu : nil
              end

              # @!attribute [r] tensuu
              #   @return [Integer, nil]
              # @!attribute [r] kaisuu
              #   @return [Integer, nil]
              attr_reader :tensuu, :kaisuu

              def_delegators :@tekiyou_items, :each, :map, :reduce
              def_delegators :first_item, :futan_kubun, :uses?

              private

              # @return [Cost, Comment]
              def first_item
                @first_item ||= tekiyou_items.first
              end

              attr_reader :tekiyou_items
            end
          end
        end
      end
    end
  end
end
