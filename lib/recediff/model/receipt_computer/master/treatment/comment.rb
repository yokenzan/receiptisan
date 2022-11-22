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

            # @param appended_content [
            #   AppendedContent::FreeFormat,
            #   AppendedContent::DayHourMinuteFormat,
            #   AppendedContent::HourMinuteFormat,
            #   AppendedContent::MinuteFormat,
            #   AppendedContent::NumberFormat,
            #   AppendedContent::ShinryouKouiFormat,
            #   AppendedContent::ShuushokugoFormat,
            #   AppendedContent::WarekiDateAndNumberFormat,
            #   AppendedContent::WarekiDateFormat,
            #   nil
            # ]
            # @return [String]
            def format(appended_content)
              unless pattern.requires_embdding?
                return \
                  case pattern.code
                  when :'10'
                    appended_content
                  when :'20'
                    name
                  else
                    [name, appended_content].join('；').squeeze('；')
                  end.to_s
              end

              comment_text  = name
              appended_text = appended_content.to_s

              comment_text.tap do | text |
                # @param position [EmbedPosition]
                @embed_positions.each do | position |
                  text[position.start - 1, position.length] = appended_text[0, position.length]
                  appended_text[0, position.length] = ''
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
            #
            # 埋込のロジックは持たない
            class EmbedPosition
              def initialize(start, length)
                @start  = start
                @length = length
              end

              attr_reader :start, :length
            end

            # コメントパターン
            #
            # テキスト生成のロジックは持たない
            class Pattern
              # @param code [Symbol]
              # @paaram requires_embdding [Boolean]
              def initialize(code, requires_embdding)
                @code              = code
                @requires_embdding = requires_embdding
              end

              def requires_embdding?
                @requires_embdding
              end

              # @!attribute [r] code
              #   @return [Symbol]
              attr_reader :code

              @patterns = {
                '10': new(:'10', false),
                '20': new(:'20', false),
                '30': new(:'30', false),
                '31': new(:'31', false),
                '40': new(:'40', true),
                '42': new(:'42', false),
                '50': new(:'50', false),
                '51': new(:'51', false),
                '52': new(:'52', false),
                '53': new(:'53', false),
                '80': new(:'80', false),
                '90': new(:'90', false),
              }

              class << self
                # @code [String, Integer, Symbol]
                # @return [self, nil]
                def find_by_code(code)
                  @patterns[code.to_s.intern]
                end
              end
            end

            # 「文字データ」として補足される追記テキスト
            module AppendedContent
              # フォーマットが定められていない任意形式の文字列
              #
              # パターン10, 30
              class FreeFormat
                # @param value [String]
                def initialize(value)
                  @value = value
                end

                def to_s
                  @value
                end
              end

              # 診療行為による補足
              #
              # パターン31
              class ShinryouKouiFormat
                # @param master_shinryou_koui [Master::Treatment::ShinryouKoui]
                def initialize(master_shinryou_koui)
                  @shinryou_koui = master_shinryou_koui
                end

                def to_s
                  @shinryou_koui.name
                end
              end

              # 数値による補足
              #
              # パターン40, 42
              class NumberFormat
                # @param value [String] 全角数字による数値文字列
                def initialize(value)
                  @value = value
                end

                def to_s
                  @value
                end
              end

              # 和暦年月日による補足
              #
              # パターン50
              class WarekiDateFormat
                def initialize(wareki, date)
                  @value = wareki
                  @date  = date
                end

                def to_s
                  text = '%s%s年%s月%s日' % [
                    Util::DateUtil::Gengou.find_by_alphabet(@date.jisx0301[0]).name,
                    @value[1, 2],
                    @value[3, 2],
                    @value[5, 2],
                  ]
                  text.gsub!(/０([０-９])/, '　\1')
                end
              end

              # 時・分による補足
              #
              # パターン51
              class HourMinuteFormat
                # @param hour_minute [String] 全角数字による数値文字列
                def initialize(hour, minute)
                  @hour   = hour
                  @minute = minute
                end

                def to_s
                  '%s時%s分' % [@hour, @minute]
                end
              end

              # 分による補足
              #
              # パターン52
              class MinuteFormat
                # @param minute [String] 全角数字による数値文字列
                def initialize(minute)
                  @minute = minute
                end

                def to_s
                  '%s分' % @minute
                end
              end

              # 日・時・分による補足
              #
              # パターン53
              class DayHourMinuteFormat
                # @param hour_minute [String] 全角数字による数値文字列
                def initialize(day, hour, minute)
                  @day    = day
                  @hour   = hour
                  @minute = minute
                end

                def to_s
                  '%s日%s時%s分' % [@day, @hour, @minute]
                end
              end

              # 和暦年月日・数値による補足
              #
              # パターン80
              class WarekiDateAndNumberFormat
                def initialize(wareki_date_format, number_format)
                  @wareki = wareki_date_format
                  @number = number_format
                end

                def to_s
                  '%s%s' % [@wareki, @number]
                end
              end

              # 修飾語による補足
              #
              # パターン90
              class ShuushokugoFormat
                # @param master_shuushokugos [Array<Master::Diagnosis::Shuushokugo>]
                def initialize(*master_shuushokugos)
                  @shuushokugos = master_shuushokugos
                end

                def to_s
                  @shuushokugos.map(&:name).join
                end
              end
            end

            # rubocop:disable Layout/SpaceAroundOperators, Layout/ExtraSpacing
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
            # rubocop:enable Layout/SpaceAroundOperators, Layout/ExtraSpacing
          end
        end
      end
    end
  end
end
