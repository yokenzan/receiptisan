# frozen_string_literal: true

module Receiptisan
  module Util
    module WarekiExtension
      refine Date do
        # @return [String]
        def to_wareki(zenkaku: false)
          Receiptisan::Util::DateUtil.to_wareki(self, zenkaku: zenkaku)
        end
      end

      refine Month do
        # @return [String]
        def to_wareki(zenkaku: false)
          Receiptisan::Util::DateUtil.to_wareki(self, zenkaku: zenkaku)
        end
      end
    end
  end
end
