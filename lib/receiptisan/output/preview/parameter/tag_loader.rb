# frozen_string_literal: true

require 'pathname'
require 'yaml'

module Receiptisan
  module Output
    module Preview
      module Parameter
        class TagLoader
          CONFIG_DIR = __dir__ + '/../../../../../config'
          Tag        = Struct.new(:name, :label, :shinryou_shikibetsu, :code, keyword_init: true) do
            class << self
              # @return [self]
              def from(definition)
                new(
                  name:                definition['name'].intern,
                  label:               definition['label'],
                  shinryou_shikibetsu: definition['shinryou_shikibetsu'],
                  code:                definition['code'].map { | code | code.to_s.intern }
                )
              end
            end
          end

          def load(version, root_dir = CONFIG_DIR)
            tag_file = resolve(version, root_dir) + 'tag.yml'
            hash     = YAML.load_file(tag_file.to_path)
            hash['tags'].to_h { | tag_def | [tag_def['name'].intern, Tag.from(tag_def)] }
          end

          private

          # @param version [Version]
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
