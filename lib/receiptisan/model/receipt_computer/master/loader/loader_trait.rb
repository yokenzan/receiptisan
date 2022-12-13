# frozen_string_literal: true

require 'nkf'

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class Loader
          # 各マスターファイルのローダーで使う共通関数の詰合わせ
          module LoaderTrait
            # マスターファイルの文字コード
            MASTER_CSV_ENCODING = 'Shift_JIS'

            # simple copy of `CSV.foreach()`
            #
            # @param csv_paths [Array<String>]
            # @return [void]
            # @yieldparam [Array<String, NilClass>] values
            # @yieldreturn [void]
            def foreach(csv_paths)
              csv_paths.each do | csv_path |
                File.open(csv_path, "r:#{MASTER_CSV_ENCODING}:UTF-8") do | f |
                  f.each_line(chomp: true) { | line | yield line.tr('"', '').split(',') }
                end
              end
            end

            # 半角カナ→全角カナに変換する
            #
            # @param hankaku [String]
            # @return [String]
            def convert_katakana(hankaku)
              NKF.nkf('-wWX', hankaku)
            end
          end
        end
      end
    end
  end
end
