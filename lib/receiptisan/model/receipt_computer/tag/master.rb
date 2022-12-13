# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Tag
        class Master
          # @param version [Receiptisan::Model::ReceiptComputer::Master::Version]
          # @param tags [Hash<String, Tag>]
          def initialize(version:, tags:)
            @version = version
            @tags    = tags
          end

          # @param tag_key [String, Symbol]
          # @return [Tag, nil]
          def find_by_key(tag_key)
            @tags[tag_key.to_s.intern]
          end

          # @!attribute [r] version
          #   @return [Receiptisan::Model::ReceiptComputer::Master::Version]
          attr_reader :version
        end
      end
    end
  end
end
