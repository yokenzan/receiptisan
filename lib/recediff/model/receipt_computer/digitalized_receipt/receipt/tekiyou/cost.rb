# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Cost
              extend Forwardable

              # @param resource [ShinryouKoui, Iyakuhin, TokuteiKizai] 医療資源
              # @param shinryou_shikibetsu [ShinryouShikibetsu] 診療識別
              # @param futan_kubun [FutanKubun] 負担区分
              # @param tensuu [Integer, nil] 算定点数
              # @param kaisuu [Integer, nil] 算定回数
              def initialize(
                resource:,
                shinryou_shikibetsu:,
                futan_kubun:,
                tensuu:,
                kaisuu:
              )
                @resource            = resource
                @shinryou_shikibetsu = shinryou_shikibetsu
                @futan_kubun         = futan_kubun
                @tensuu              = tensuu&.to_i
                @kaisuu              = kaisuu&.to_i
                @comments            = []
              end

              # @param comment [Comment]
              # @return [void]
              def add_comment(comment)
                @comments << comment
              end

              def has_comments? # rubocop:disable Naming/PredicateName
                !@comments.empty?
              end

              # # @param day [Integer]
              # # @return [Integer]
              # def kaisuu_at(day)
              #   days[day - 1].to_i
              # end
              #
              # # @param day [Integer]
              # # @return [Boolean]
              # def done_at?(day)
              #   kaisuu_at(day).positive?
              # end
              #
              # def done_at_breakdown; end
              #
              # def kaisuu_at_breakdown; end

              # 算定点数の記載があるか？
              def tensuu?
                !tensuu.nil?
              end

              # 算定回数の記載があるか？
              def kaisuu?
                !kaisuu.nil?
              end

              def comment?
                false
              end

              def each_comment(&block)
                enum = @comments.enum_for(:each)

                block_given? ? enum.each(&block) : enum
              end

              # def to_s
              #   @resource.to_s
              # end

              # @!attribute [r] resource
              #   @return [ShinryouKoui, Iyakuhin, TokuteiKizai] 医療資源
              # @!attribute [r] futan_kubun
              #   @return [FutanKubun]負担区分
              # @!attribute [r] tensuu
              #   @return [Integer, nil] 算定点数
              # @!attribute [r] kaisuu
              #   @return [Integer, nil] 算定回数
              # @!attribute [r] shinryou_shikibetsu
              #   @return [ShinryouShikibetsu] 診療識別
              attr_reader :resource, :futan_kubun, :tensuu, :kaisuu, :shinryou_shikibetsu

              private

              attr_reader :days
            end
          end
        end
      end
    end
  end
end
