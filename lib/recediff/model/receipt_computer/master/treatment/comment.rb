# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class Master
        module Treatment
          # コメント
          class Comment
            # @param code [CommentCode]
            # @param pattern [String]
            # @param name [String]
            # @param name_kana [String]
            def initialize(code:, pattern:, name:, name_kana:, embed_positions:)
              @code            = code
              @pattern         = pattern
              @name            = name
              @name_kana       = name_kana
              @embed_positions = embed_positions
            end

            # @param additional_text [String, nil]
            def format_with(additional_text); end

            # @!attribute [r] code
            #   @return [CommentCode]
            attr_reader :code
            # @!attribute [r] name
            #   @return [String]
            attr_reader :name
            # @!attribute [r] name_kana
            #   @return [String]
            attr_reader :name_kana

            # 追記テキストを `コメント文_漢字名称` に埋込む位置情報
            class EmbedPosition
              def initialize(position, length)
                @position = position
                @length   = length
              end

              attr_reader :position, :length
            end

            module Columns
              C_変更区分                      = 0
              C_マスター種別                  = 1
              C_区分                          = 2
              C_パターン                      = 3
              C_一連番号                      = 4
              C_コメント文_漢字有効桁数       = 5
              C_コメント文_漢字名称           = 6
              C_コメント文_カナ有効桁数       = 7
              C_コメント文_カナ名称           = 8
              C_レセプト編集情報_1_カラム位置 = 9
              C_レセプト編集情報_1_桁数       = 10
              C_レセプト編集情報_2_カラム位置 = 11
              C_レセプト編集情報_2_桁数       = 12
              C_レセプト編集情報_3_カラム位置 = 13
              C_レセプト編集情報_3_桁数       = 14
              C_レセプト編集情報_4_カラム位置 = 15
              C_レセプト編集情報_4_桁数       = 16
              C_予備_1                        = 17
              C_予備_2                        = 18
              C_選択式コメント識別            = 19
              C_変更年月日                    = 20
              C_廃止年月日                    = 21
              C_コード                        = 22
              C_公表順序番号                  = 23
            end
          end
        end
      end
    end
  end

