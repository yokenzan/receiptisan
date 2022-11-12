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

            # @param additional_comment [ReceiptComputer::DigitalizedReceipt::Receipt::Comment::AdditionalComment, nil]
            def format_with(additional_comment)
              additional_text = @pattern.format(name, additional_comment)
              return [name, additional_text].reject(&:empty?).join('；').squeeze('；') unless pattern.needs_embdding?

              comment_text = name
              comment_text.tap do | text |
                # @param position [EmbedPosition]
                @embed_positions.each do | position |
                  text[position.start - 1, position.length] = additional_text[0, position.length]
                  additional_text[0, position.length]       = ''
                end
              end
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
            # @!attribute [r] pattern
            #   @return [Pattern]
            attr_reader :pattern

            # コメントコード
            class Code
              include MasterItemCodeInterface

              class << self
                def __name
                  'コメント'
                end
              end
            end

            # 追記テキストを `コメント文_漢字名称` に埋込む位置情報
            class EmbedPosition
              def initialize(start, length)
                @start  = start
                @length = length
              end

              attr_reader :start, :length
            end

            class Pattern
              # @param code [Symbol]
              # @paaram needs_embdding [Boolean]
              # @param formatter [Proc]
              def initialize(code, needs_embdding, formatter)
                @code           = code
                @needs_embdding = needs_embdding
                @formatter      = formatter
              end

              def needs_embdding?
                @needs_embdding
              end

              # @return [String]
              def format(name, additional_comment)
                @formatter.call(name, additional_comment)
              end

              # @!attribute [r] code
              #   @return [Symbol]
              attr_reader :code

              @patterns = {
                '10': new(:'10', false, proc { | _, additional_comment | additional_comment.value }),
                '20': new(:'20', false, proc { | name, _ | name }),
                '30': new(:'30', false, proc { | _, additional_comment | additional_comment.value }),
                '31': new(:'31', false, proc { | _, additional_comment | additional_comment.item.name }),
                '40': new(:'40', true,  proc { | _, additional_comment | additional_comment.value }),
                '42': new(:'42', false, proc { | _, additional_comment | additional_comment.value }),
                '50': new(:'50', false, proc { | _, additional_comment | Recediff::Util::DateUtil.to_wareki(additional_comment.item) }),
                '51': new(:'51', false, proc { | _, additional_comment | additional_comment.item }),
                '52': new(:'52', false, proc { | _, additional_comment | additional_comment.item }),
                '53': new(:'53', false, proc { | _, additional_comment | additional_comment.item }),
                '80': new(:'80', false, proc { | _, additional_comment | additional_comment.item.name }),
                '90': new(:'90', false, proc { | _, additional_comment | additional_comment.item.name }),
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
