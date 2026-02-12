# frozen_string_literal: true

require 'forwardable'
require 'nkf'

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class Loader
          # 各マスターファイルのローダーで使う共通関数の詰合わせ
          module LoaderTrait
            extend Forwardable

            # マスターファイルの文字コード
            MASTER_CSV_ENCODING = 'Shift_JIS'

            # simple copy of `CSV.foreach()`
            #
            # @param csv_paths [Array<Pathname>]
            # @return [void]
            # @yieldparam [Array<String, NilClass>] values
            # @yieldreturn [void]
            def foreach(csv_paths)
              logger.info 'prepare to load following CSV %d files:' % csv_paths.length
              logger.info csv_paths.map(&:to_path)

              csv_paths.each do | csv_path |
                lines = File.read(csv_path, mode: "r:#{MASTER_CSV_ENCODING}:UTF-8").split("\n")

                lines.each do | line |
                  yield line.delete_suffix("\r").tr('"', '').split(',')
                end

                logger.info "#{csv_path}(#{lines.length} lines) was loaded."
              end
            end

            private

            def logger
              raise NotImplementedError, 'should override #logger'
            end

            def_delegators Receiptisan::Util::Formatter,
              :convert_katakana,
              :convert_unit,
              :replace_kakkotsuki_mark
          end
        end
      end
    end
  end
end
