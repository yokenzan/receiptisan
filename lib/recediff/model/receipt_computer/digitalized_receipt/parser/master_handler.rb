# frozen_string_literal: true

require 'month'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          class MasterHandler
            # @param master_loader [Master::Loader]
            def initialize(master_loader)
              @master_loader  = master_loader
              # @type [Hash<Master::Version, Master>]
              @loaded_masters = {}
              # @type [Master, nil]
              @current_master = nil
            end

            # 新しいレセプトを読込む都度、レセプトの診療年月にあわせた版のマスタを用意する
            #
            # @param shinryou_ym [Month]
            # @return [Master]
            def prepare(shinryou_ym)
              version = Master::Version.resolve_by_ym(shinryou_ym)
              @loaded_masters[version] ||= @master_loader.load(version)
            end
          end
        end
      end
    end
  end
end
