# frozen_string_literal: true

module Receiptisan
  module Util
    module Formatter
      MARU_ICHI_CODEPOINT = 0x2460 # ①のコードポイント
      HANKAKU_CHARS       = '−() A-Za-z0-9.'
      ZENKAKU_CHARS       = '―（）　Ａ-Ｚａ-ｚ０-９．'

      # カンマ区切り表記にする
      # @param integer [Integer, nil] nilの場合は空文字列を返します
      # @return [String]
      def to_currency(integer)
        return '' if integer.nil?

        integer.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
      end

      # マル付数字の文字を生成する
      # @param zero_based_index [Integer]
      # @return [String]
      def to_marutsuki_mark(zero_based_index)
        (MARU_ICHI_CODEPOINT + zero_based_index).chr('UTF-8')
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
    end
  end
end
