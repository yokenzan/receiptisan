# frozen_string_literal: true

require 'month'
require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          # コメントの文字データを適切なオブジェクトにするビルダー
          class CommentContentBuilder
            include Master::Treatment::Comment::AppendedContent
            @@patterns = {
              '10': proc { | appended_value | FreeFormat.new(appended_value) },
              '20': proc {},
              '30': proc { | appended_value | FreeFormat.new(appended_value) },
              '31': proc do | shinryou_koui_code, handler |
                ShinryouKouiFormat.new(
                  handler.find_by_code(Master::Treatment::ShinryouKoui::Code.of(to_half_number(shinryou_koui_code)))
                )
              end,
              '40': proc { | number | NumberFormat.new(number) },
              '42': proc { | number | NumberFormat.new(number) },
              '50': proc do | wareki_date |
                WarekiDateFormat.new(wareki_date, Recediff::Util::DateUtil.parse_date(wareki_date))
              end,
              '51': proc { | hour_minute | HourMinuteFormat.new(hour_minute[0, 2], hour_minute[2, 2]) },
              '52': proc { | minute | MinuteFormat.new(minute) },
              '53': proc do | day_hour_minute |
                DayHourMinuteFormat.new(
                  _day    = day_hour_minute[0, 2],
                  _hour   = day_hour_minute[2, 2],
                  _minute = day_hour_minute[4, 2]
                )
              end,
              '80': proc do | wareki_and_number |
                WarekiDateAndNumberFormat.new(
                  @@patterns[:'40'].call(wareki_and_number[0, 7]),
                  @@patterns[:'42'].call(wareki_and_number[-8..])
                )
              end,
              '90': proc do | code_of_shuushokugos, handler |
                shuushokugos = code_of_shuushokugos.scan(/\d{4}/).map do | code |
                  handler.find_by_code(Master::Diagnosis::Shuushokugo::Code.of(to_half_number(code)))
                end
                ShuushokugoFormat.new(*shuushokugos)
              end,
            }

            def initialize(handler)
              @handler = handler
            end

            # @param pattern [Master::Treatment::Comment::Pattern]
            def build(pattern, appended_value)
              @@patterns[pattern.code].call(appended_value, @handler)
            end

            private

            # 全角数字を半角数字に変換する
            #
            # @param number_format [String]
            # @return [String]
            def to_half_number(number_format)
              number_format.tr('０-９', '0-9')
            end
          end
        end
      end
    end
  end
end