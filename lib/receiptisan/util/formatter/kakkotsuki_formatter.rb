# frozen_string_literal: true

module Receiptisan
  module Util
    module Formatter
      module KakkotsukiFormatter
        Formatter = ::Receiptisan::Util::Formatter

        KAKKO_ICHI_CODEPOINT = 0x2474 # ⑴のコードポイント
        TARGET_RANGE         = (1..20).freeze

        # カッコ付数字の文字が含まれていたら置換する
        # @return [String]
        def format(string)
          string.gsub(/（([１-９][０-９]*)）/) do
            matched_number = ::Regexp.last_match(1)
            number = Formatter.to_hankaku(matched_number).to_i
            convertable?(number) ? convert(number - 1) : matched_number
          end
        end

        # カッコ付数字の文字を生成する
        # @param zero_based_index [Integer]
        # @return [String]
        def convert(zero_based_index)
          # 用意されている文字はカッコ20まで
          unless convertable?(zero_based_index + 1)
            min = TARGET_RANGE.begin - 1
            max = TARGET_RANGE.end - 1

            raise ArgumentError, "given index is out of range (#{min}~#{max}): '#{zero_based_index}'"
          end

          (KAKKO_ICHI_CODEPOINT + zero_based_index).chr('UTF-8')
        end

        def convertable?(number)
          number.between?(TARGET_RANGE.begin, TARGET_RANGE.end)
        end

        module_function :format, :convert, :convertable?
      end
    end
  end
end
