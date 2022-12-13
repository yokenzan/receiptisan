# frozen_string_literal: true

require 'pathname'
require 'yaml'

module Receiptisan
  module Model
    module ReceiptComputer
      module Abbrev
        class Loader
          CONFIG_DIR = __dir__ + '/../../../../../config'

          # @param version [Receiptisan::Model::ReceiptComputer::Master::Version]
          # @param root_dir [String]
          # @return [Master]
          def load(version, root_dir = CONFIG_DIR)
            abbrev_file = resolve(version, root_dir) + 'abbrev.yml'
            hash        = YAML.load_file(abbrev_file.to_path)

            Master.new(
              version: version,
              abbrevs: hash['labels'].map { | abbrev_def | Abbrev.from(abbrev_def) }.group_by(&:code)
            )
          end

          private

          # @param version [Receiptisan::Model::ReceiptComputer::Master::Version]
          # @param root_dir [String]
          # @return [Pathname]
          def resolve(version, root_dir)
            pathname  = Pathname.new(root_dir)
            pathname += version.year.to_s
            pathname.expand_path(__dir__)
          end
        end
      end
    end
  end
end
