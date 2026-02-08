# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        # レセ電コードからマスター種別を解決する
        #
        # コード桁数とプレフィクスの対応:
        #   4桁      => 修飾語 (shuushokugo)
        #   7桁      => 傷病名 (shoubyoumei)
        #   9桁 先頭1 => 診療行為 (shinryou_koui)
        #   9桁 先頭6 => 医薬品 (iyakuhin)
        #   9桁 先頭7 => 特定器材 (tokutei_kizai)
        #   9桁 先頭8 => コメント (comment)
        module CodeTypeResolver
          TREATMENT_PREFIX_MAP = {
            '1' => :shinryou_koui,
            '6' => :iyakuhin,
            '7' => :tokutei_kizai,
            '8' => :comment,
          }.freeze

          LENGTH_MAP = {
            4 => :shuushokugo,
            7 => :shoubyoumei,
          }.freeze

          class << self
            # @param code [String] レセ電コード
            # @return [Symbol] マスター種別
            # @raise [ArgumentError] 種別を判定できない場合
            def resolve(code)
              LENGTH_MAP.fetch(code.length) { resolve_treatment_type(code) }
            end

            private

            # @param code [String] 9桁のレセ電コード
            # @return [Symbol]
            # @raise [ArgumentError]
            def resolve_treatment_type(code)
              raise ArgumentError, "コード '#{code}' (#{code.length}桁) から種別を判定できません" unless code.length == 9

              TREATMENT_PREFIX_MAP.fetch(code[0]) do
                raise ArgumentError, "コード '#{code}' の先頭桁 '#{code[0]}' から種別を判定できません"
              end
            end
          end
        end
      end
    end
  end
end
