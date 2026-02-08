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
                @tensuu         = nil
                # @type kaisuu [Integer, nil]
                @kaisuu         = nil
                # @type tekiyou_items [Array<Cost, Comment>]
                @tekiyou_items  = []
                # @type daily_kaisuus [Array<DailyKaisuu>]
                @daily_kaisuus  = []
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

              # @return [Integer, nil]
              def calculate
                tensuu && kaisuu ? tensuu * kaisuu : nil
              end

              # @return [Enumerator<DailyKaisuu>]
              def each_date(&)
                enum = @daily_kaisuus.enum_for(:each)

                block_given? ? enum.each(&) : enum
              end

              # @param date [Date]
              # @return [Boolean]
              def on_date?(date)
                @daily_kaisuus.any? { | dk | dk.on?(date) }
              end

              # @param date [Date]
              # @return [SanteiUnit, nil]
              def on_date(date)
                matched = @daily_kaisuus.select { | dk | dk.on?(date) }
                return nil if matched.empty?

                dup.tap { | unit | unit.instance_variable_set(:@daily_kaisuus, matched) }
              end

              # @!attribute [r] tensuu
              #   @return [Integer, nil]
              # @!attribute [r] kaisuu
              #   @return [Integer, nil]
              # @!attribute [r] daily_kaisuus
              #   @return [Array<DailyKaisuu>]
              attr_reader :tensuu, :kaisuu, :daily_kaisuus

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
