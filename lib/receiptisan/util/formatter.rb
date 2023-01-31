# frozen_string_literal: true

require_relative 'formatter/kakkotsuki_formatter'

module Receiptisan
  module Util
    module Formatter
      MARU_ICHI_CODEPOINT    = 0x2460 # ①～⑳のコードポイント
      MARU_ICHI_CODEPOINT_21 = 0x3251 # ㉑以降のコードポイント
      MARU_ICHI_CODEPOINT_36 = 0x32b1 # ㊱以降のコードポイント
      HANKAKU_CHARS          = '−() A-Za-z0-9.'
      ZENKAKU_CHARS          = '―（）　Ａ-Ｚａ-ｚ０-９．'

      # カンマ区切り表記にする
      # @param integer [Integer, nil] nilの場合は空文字列を返します
      # @return [String]
      def to_currency(value)
        return '' unless value.respond_to?(:to_i)

        value.to_i.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
      end

      # マル付数字の文字を生成する
      # @param zero_based_index [Integer]
      # @return [String]
      def to_marutsuki_mark(zero_based_index)
        # 用意されている文字はマル50まで
        raise ArgumentError, "given index is out of range (0~49): '#{zero_based_index}'" if zero_based_index >= 50

        codepoint = \
          case # rubocop:disable Style/EmptyCaseCondition
          when zero_based_index < 20
            MARU_ICHI_CODEPOINT + zero_based_index
          when zero_based_index < 35
            MARU_ICHI_CODEPOINT_21 + zero_based_index - 20
          else
            MARU_ICHI_CODEPOINT_36 + zero_based_index - 35
          end

        codepoint.chr('UTF-8')
      end

      # @return [String]
      def replace_kakkotsuki_mark(string)
        KakkotsukiFormatter.format(string)
      end

      # @param value [String, Symbol, Integer, nil] nilの場合は空文字列を返します
      # @return [self]
      def to_zenkaku(value)
        return '' if value.nil?

        value.to_s.tr(HANKAKU_CHARS, ZENKAKU_CHARS)
      end

      # @param value [String, Symbol, Integer, nil] nilの場合は空文字列を返します
      # @return [self]
      def to_hankaku(value)
        return '' if value.nil?

        value.to_s.tr(ZENKAKU_CHARS, HANKAKU_CHARS)
      end

      # 半角カナ→全角カナに変換する
      #
      # @param hankaku [String]
      # @return [String]
      def convert_katakana(hankaku)
        NKF.nkf('-wWX', hankaku)
      end

      def convert_unit(string)
        string
          .gsub('ｍＬＶ', '㎖Ｖ')
          .gsub('ｍＬ', '㎖')
          .gsub(/(?<=[０-９])Ｌ\b/, 'ℓ')
          .gsub('ｍｇ', '㎎')
          .gsub('ｋｇ', '㎏')
          .gsub('μｇ', '㎍')
          .gsub('ｃｃ', '㏄')
          .gsub('ｃｍ２', '㎠')
          .gsub('ｃｍ', '㎝')
          .gsub('ｎｍ', '㎚')
      end
    end
  end
end
