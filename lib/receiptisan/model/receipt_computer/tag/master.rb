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

          # @param tag_name [String]
          # @return [Tag, nil]
          def find_by_name(tag_name)
            @tags[tag_name.to_s.intern]
          end

          # @!attribute [r] version
          #   @return [Receiptisan::Model::ReceiptComputer::Master::Version]
          attr_reader :version
        end
      end
    end
  end
end
