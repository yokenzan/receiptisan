# frozen_string_literal: true

module Receiptisan
  module Util
    module RecursivelyHashConvertable
      refine Object do
        def to_hash_recursively
          self
        end
      end

      refine Array do
        def to_hash_recursively
          map(&:to_hash_recursively)
        end
      end

      refine Symbol do
        def to_hash_recursively
          to_s
        end
      end

      refine Struct do
        def to_hash_recursively
          to_h { | key, value | [key.to_s, value.to_hash_recursively] }
        end
      end

      refine Hash do
        def to_hash_recursively
          to_h { | key, value | [key.to_s, value.to_hash_recursively] }
        end
      end
    end
  end
end
