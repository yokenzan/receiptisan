# frozen_string_literal: true

require 'pathname'

module Recediff
  module Model
    module ReceiptComputer
      class Master
        class ResourceResolver
          # レセプト電算処理システム基本マスターファイルのディレクトリへの相対パス
          MASTER_CSV_DIR = '../../../../../csv/master'

          # @param version [Version]
          # @return [Hash<Symbol, String>]
          def detect_csv_files(version)
            pathname       = resolve_csv_dir_of(version)
            csv_files      = pathname.children
            detected_paths = {}
            csv_prefixes   = {
              shinryou_koui: 's',
              iyakuhin:      'y',
              tokutei_kizai: 't',
              comment:       'c',
              shoubyoumei:   'b',
              shuushokugo:   'z',
            }

            csv_prefixes.each do | key, value |
              detected_paths["#{key}_csv_path".intern] = csv_files.delete_at(
                # @param csv [Pathname]
                csv_files.find_index { | csv | csv.basename.to_path.start_with?(value) }
              )
            end

            detected_paths
          end

          private

          # @param version [Version]
          # @return [Pathname]
          def resolve_csv_dir_of(version)
            pathname  = Pathname.new(MASTER_CSV_DIR)
            pathname += version.year.to_s
            pathname.expand_path(__dir__)
          end
        end
      end
    end
  end
end
