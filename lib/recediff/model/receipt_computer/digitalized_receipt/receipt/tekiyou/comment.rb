# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            # コメント
            class Comment
              extend Forwardable

              # @param item [Master::Treatment::Comment]
              # @param appended_content [Object, nil] コメント文
              # @param shinryou_shikibetsu [ShinryouShikibetsu, nil] 診療識別
              # @param futan_kubun [FutanKubun] 負担区分
              def initialize(
                master_item:,
                appended_content:,
                shinryou_shikibetsu:,
                futan_kubun:
              )
                @master_item         = master_item
                @appended_content    = appended_content
                @shinryou_shikibetsu = shinryou_shikibetsu
                @futan_kubun         = futan_kubun
              end

              def tensuu?
                false
              end

              def kaisuu?
                false
              end

              def comment?
                true
              end

              # @!attribute [r] item
              #   @return [Master::Treatment::Comment]
              # @!attribute [r] appended_content
              #   @return [Object, nil]
              # @!attribute [r] shinryou_shikibetsu
              #   @return [ShinryouShikibetsu, nil]
              # @!attribute [r] futan_kubun
              #   @return [FutanKubun]
              attr_reader :master_item, :appended_content, :shinryou_shikibetsu, :futan_kubun

              # @!attribute [r] code
              #   @return [Master::Treatment::Comment::Code]
              # @!attribute [r] pattern
              #   @return [Master::Treatment::Comment::Pattern]
              def_delegators :master_item, :code, :pattern
            end
          end
        end
      end
    end
  end
end
