# frozen_string_literal: true

require 'pathname'

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class ResourceResolver
          # レセプト電算処理システム基本マスターファイルのディレクトリへの相対パス
          MASTER_CSV_DIR = '../../../../../csv/master'

          # @param version [Version]
          # @param root_dir [String]
          # @return [Hash<Symbol, String>]
          def detect_csv_files(version, root_dir = MASTER_CSV_DIR)
            pathname       = resolve_csv_dir_of(version, root_dir)
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
          # @param root_dir [String]
          # @return [Pathname]
          def resolve_csv_dir_of(version, root_dir)
            pathname  = Pathname.new(root_dir)
            pathname += version.year.to_s
            pathname.expand_path(__dir__)
          end
        end
      end
    end
  end
end
