# frozen_string_literal: true

require 'forwardable'
require 'nkf'
require 'pathname'

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
                load_path, read_encoding = resolve_load_path(csv_path)
                lines = File.read(load_path, mode: "r:#{read_encoding}:UTF-8").split("\n")

                lines.each do | line |
                  yield line.delete_suffix("\r").tr('"', '').split(',')
                end

                logger.info "#{load_path}(#{lines.length} lines) was loaded."
              end
            end

            private

            # UTF-8 変換済みファイルがあれば優先して読み込む
            #
            # @param csv_path [Pathname, String]
            # @return [Array<Pathname, String>]
            def resolve_load_path(csv_path)
              path      = Pathname(csv_path)
              utf8_path = path.dirname.join('utf8', path.basename.to_path)
              return [utf8_path, 'UTF-8'] if utf8_path.exist?

              [path, MASTER_CSV_ENCODING]
            end

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
