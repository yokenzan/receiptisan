# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class Master
        module Treatment
          # コメント
          class Comment
            # @param code [CommentCode]
            # @param pattern [Pattern]
            # @param name [String]
            # @param name_kana [String]
            # @param embed_positions [Array<EmbedPosition>]
            def initialize(code:, pattern:, name:, name_kana:, embed_positions:)
              @code            = code
              @pattern         = pattern
              @name            = name
              @name_kana       = name_kana
              @embed_positions = embed_positions
            end

            # @param additional_text [String, nil]
            def format_with(additional_text)
              @pattern.format_with(name, additional_text, @embed_positions)
              # @param position [EmbedPosition]
              # @embed_positions.each do | position |
              #   text[position.start - 1, position.length] = additional_text[0, position.length]
              #   additional_text[0, position.length] = ''
              # end
            end

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
              def initialize(start, length)
                @start  = start
                @length = length
              end

              attr_reader :start, :length
            end

            class Pattern
              def initialize(code, formatter)
                @code      = code
                @formatter = formatter
              end

              def format_with(comment_name, additional_text, embed_positions)
                @formatter.call(comment_name, additional_text, embed_positions)
                # @param position [EmbedPosition]
                # @embed_positions.each do | position |
                #   text[position.start - 1, position.length] = additional_text[0, position.length]
                #   additional_text[0, position.length] = ''
                # end
              end

              @patterns = {
                '10': new(:'10', lambda do | _, additional_text, _ |
                  additional_text
                end),
                '20': new(:'20', lambda do | name, _, _ |
                  name
                end),
                '30': new(:'30', lambda do | name, additional_text, _ |
                  name << additional_text
                end),
                '31': new(:'31', lambda do | name, shinryou_koui, _ |
                  [name, shinryou_koui].join('；').squeeze('；')
                  # name << shinryou_koui.name
                end),
                '40': new(:'40', lambda do | name, digits, _ |
                  name << digits
                end),
                '42': new(:'42', lambda do | name, integer, _ |
                  [name, integer].join('；').squeeze('；')
                end),
                '50': new(:'50', lambda do | name, date, _ |
                  [name, date].join('；').squeeze('；')
                end),
                '51': new(:'51', lambda do | name, time, _ |
                  [name, time].join('；').squeeze('；')
                end),
                '52': new(:'52', lambda do | name, minutes, _ |
                  [name, minutes].join('；').squeeze('；')
                end),
                '53': new(:'53', lambda do | name, day_and_time, _ |
                  [name, day_and_time].join('；').squeeze('；')
                end),
                '80': new(:'80', lambda do | name, date_and_score, _ |
                  [name, date_and_score].join('；').squeeze('；')
                end),
                '90': new(:'90', lambda do | name, shuushokugo, _ |
                  [name, shuushokugo].join('；').squeeze('；')
                end),
              }

              class << self
                # @code [String, Integer, Symbol]
                # @return [self, nil]
                def find_by_code(code)
                  @patterns[code.to_s.intern]
                end
              end
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
end
