# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Cost
              extend Forwardable

              # @param resource [Resource::ShinryouKoui, Resource::Iyakuhin, Resource::TokuteiKizai] 医療資源
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

              # @return [Symbol] one of :iyakuhin, :shinryou_koui or :tokutei_kizai
              def resource_type
                resource.type
              end

              def each_comment(&block)
                enum = @comments.enum_for(:each)

                block_given? ? enum.each(&block) : enum
              end

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

              def_delegators :futan_kubun, :uses?
            end
          end
        end
      end
    end
  end
end
