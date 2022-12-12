# frozen_string_literal: true

require 'pathname'
require 'yaml'

module Receiptisan
  module Output
    module Preview
      module Tag
        class Loader
          CONFIG_DIR = __dir__ + '/../../../../../config'

          # @param version [Receiptisan::Model::ReceiptComputer::Master::Version]
          # @param root_dir [String]
          # @return [Master]
          def load(version, root_dir = CONFIG_DIR)
            tag_file = resolve(version, root_dir) + 'tag.yml'
            hash     = YAML.load_file(tag_file.to_path)

            Master.new(
              version: version,
              tags:    hash['tags'].to_h { | tag_def | [tag_def['name'].intern, Tag.from(tag_def)] }
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
