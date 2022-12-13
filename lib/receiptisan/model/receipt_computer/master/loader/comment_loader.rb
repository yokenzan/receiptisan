# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class Loader
          class CommentLoader
            include LoaderTrait

            # @param csv_paths [Array<String>]
            # @return [Hash<Symbol, Treatment::Comment>]
            def load(csv_paths)
              embed_position_columns = [
                Treatment::Comment::Columns::C_レセプト編集情報_1_カラム位置,
                Treatment::Comment::Columns::C_レセプト編集情報_1_桁数,
                Treatment::Comment::Columns::C_レセプト編集情報_2_カラム位置,
                Treatment::Comment::Columns::C_レセプト編集情報_2_桁数,
                Treatment::Comment::Columns::C_レセプト編集情報_3_カラム位置,
                Treatment::Comment::Columns::C_レセプト編集情報_3_桁数,
                Treatment::Comment::Columns::C_レセプト編集情報_4_カラム位置,
                Treatment::Comment::Columns::C_レセプト編集情報_4_桁数,
              ]
              {}.tap do | hash |
                foreach(csv_paths) do | values |
                  embed_positions = embed_position_columns.each_slice(2).map do | column_start, column_length |
                    start  = values[column_start].to_i
                    length = values[column_length].to_i
                    next if start.zero?

                    Treatment::Comment::EmbedPosition.new(start, length)
                  end.compact

                  comment = Treatment::Comment.new(
                    code:            Treatment::Comment::Code.of(values[Treatment::Comment::Columns::C_コード]),
                    pattern:         Treatment::Comment::Pattern.find_by_code(
                      values[Treatment::Comment::Columns::C_パターン]
                    ),
                    name:            values[Treatment::Comment::Columns::C_コメント文_漢字名称],
                    name_kana:       convert_katakana(values[Treatment::Comment::Columns::C_コメント文_カナ名称]),
                    embed_positions: embed_positions
                  )

                  hash[comment.code.value] = comment
                end
              end
            end
          end
        end
      end
    end
  end
end
