# frozen_string_literal: true

module Receiptisan
  module Util
    module IOWithEncoding
      refine IO do
        def with_encoding(*enc, **options)
          original_external_encoding = external_encoding
          original_internal_encoding = internal_encoding

          set_encoding(*enc, **options)

          yield self
        ensure
          set_encoding(original_external_encoding, original_internal_encoding) unless closed?
        end
      end
    end
  end
end
