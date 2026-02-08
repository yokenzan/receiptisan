# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            # 算定日ごとの回数
            class DailyKaisuu
              # @param date [Date] 算定日
              # @param kaisuu [Integer] 回数
              def initialize(date:, kaisuu:)
                @date   = date
                @kaisuu = kaisuu
              end

              # @param date [Date]
              # @return [Boolean]
              def on?(date)
                @date == date
              end

              # @!attribute [r] date
              #   @return [Date] 算定日
              # @!attribute [r] kaisuu
              #   @return [Integer] 回数
              attr_reader :date, :kaisuu
            end

            class Cost
              extend Forwardable

              # @param resource [Resource::ShinryouKoui, Resource::Iyakuhin, Resource::TokuteiKizai] 医療資源
              # @param shinryou_shikibetsu [ShinryouShikibetsu] 診療識別
              # @param futan_kubun [FutanKubun] 負担区分
              # @param tensuu [Integer, nil] 算定点数
              # @param kaisuu [Integer, nil] 算定回数
              # @param daily_kaisuus [Array<DailyKaisuu>] 日別回数
              def initialize(
                resource:,
                shinryou_shikibetsu:,
                futan_kubun:,
                tensuu:,
                kaisuu:,
                daily_kaisuus: []
              )
                @resource            = resource
                @shinryou_shikibetsu = shinryou_shikibetsu
                @futan_kubun         = futan_kubun
                @tensuu              = tensuu&.to_i
                @kaisuu              = kaisuu&.to_i
                @daily_kaisuus       = daily_kaisuus
                @comments            = []
              end

              # @param comment [Comment]
              # @return [void]
              def add_comment(comment)
                @comments << comment
              end

              def has_comments?
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

              def each_comment(&)
                enum = @comments.enum_for(:each)

                block_given? ? enum.each(&) : enum
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
              # @!attribute [r] daily_kaisuus
              #   @return [Array<DailyKaisuu>] 日別回数
              attr_reader :resource, :futan_kubun, :tensuu, :kaisuu, :shinryou_shikibetsu, :daily_kaisuus

              def_delegators :futan_kubun, :uses?
              def_delegators :resource, :name, :code
            end
          end
        end
      end
    end
  end
end
