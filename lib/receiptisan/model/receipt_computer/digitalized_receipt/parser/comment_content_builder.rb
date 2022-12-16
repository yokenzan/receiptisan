# frozen_string_literal: true

require 'month'
require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          # コメントの文字データを適切なオブジェクトにするビルダー
          class CommentContentBuilder
            include Master::Treatment::Comment::AppendedContent
            Formatter = Receiptisan::Util::Formatter
            Pattern   = Master::Treatment::Comment::Pattern
            DateUtil  = Receiptisan::Util::DateUtil

            @@patterns = {
              Pattern::APPEND_FREE => proc { | appended_value | FreeFormat.new(appended_value) },
              Pattern::NO_APPEND => proc {},
              Pattern::APPEND_FREE => proc { | appended_value | FreeFormat.new(appended_value) },
              Pattern::APPEND_SHINRYOU_KOUI => proc do | shinryou_koui_code, handler |
                ShinryouKouiFormat.new(
                  handler.find_by_code(
                    Master::Treatment::ShinryouKoui::Code.of(Formatter.to_hankaku(shinryou_koui_code))
                  )
                )
              end,
              Pattern::APPEND_DIGITS => proc { | number | NumberFormat.new(number) },
              Pattern::APPEND_NUMBER => proc { | number | NumberFormat.new(number) },
              Pattern::APPEND_WAREKI => proc do | wareki_date |
                WarekiDateFormat.new(wareki_date, DateUtil.parse_date(wareki_date))
              rescue Date::Error
                FreeFormat.new(DateUtil.to_wareki(DateUtil.parse_year_month(wareki_date[0..-3])))
              end,
              Pattern::APPEND_HOUR_MINUTE => proc do | hour_minute |
                HourMinuteFormat.new(hour_minute[0, 2], hour_minute[2, 2])
              end,
              Pattern::APPEND_MINUTE => proc { | minute | MinuteFormat.new(minute) },
              Pattern::APPEND_DAY_HOUR_MINUTE => proc do | day_hour_minute |
                DayHourMinuteFormat.new(
                  _day    = day_hour_minute[0, 2],
                  _hour   = day_hour_minute[2, 2],
                  _minute = day_hour_minute[4, 2]
                )
              end,
              Pattern::APPEND_WAREKI_NUMBER => proc do | wareki_and_number |
                WarekiDateAndNumberFormat.new(
                  @@patterns[Pattern::APPEND_DIGITS].call(wareki_and_number[0, 7]),
                  @@patterns[Pattern::APPEND_NUMBER].call(wareki_and_number[-8..])
                )
              end,
              Pattern::APPEND_SHUUSHOKUGOS => proc do | code_of_shuushokugos, _handler, sy_processor |
                shuushokugos = sy_processor.process_shuushokugos(Formatter.to_hankaku(code_of_shuushokugos))
                ShuushokugoFormat.new(*shuushokugos)
              end,
            }

            def initialize(handler, sy_processor)
              @handler      = handler
              @sy_processor = sy_processor
            end

            # @param pattern [Master::Treatment::Comment::Pattern]
            def build(pattern, appended_value)
              @@patterns[pattern&.code || Pattern::FREE].call(appended_value, @handler, @sy_processor)
            end
          end
        end
      end
    end
  end
end
