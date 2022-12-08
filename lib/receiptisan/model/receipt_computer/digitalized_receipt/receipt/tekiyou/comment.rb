# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            # コメント
            class Comment
              extend Forwardable
              Formatter = Receiptisan::Util::Formatter

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

              def format
                master_item.format(appended_content)
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
              def_delegators :master_item, :code, :name, :pattern

              def_delegators :futan_kubun, :uses?

              class << self
                # @return [self]
                def dummy(code:, appended_content:, shinryou_shikibetsu:, futan_kubun:)
                  new(
                    master_item:         DummyMasterComment.new(code),
                    appended_content:    appended_content,
                    shinryou_shikibetsu: shinryou_shikibetsu,
                    futan_kubun:         futan_kubun
                  )
                end
              end

              # マスタに医薬品コードが見つからなかった医薬品
              DummyMasterComment = Struct.new(:code) do
                # @return [String]
                def name
                  Formatter.to_zenkaku '【不明なコメント：%s】' % code.value
                end

                def format(appended_content)
                  [name, appended_content].join('；').squeeze('；')
                end

                def pattern
                  nil
                end
              end
            end
          end
        end
      end
    end
  end
end
