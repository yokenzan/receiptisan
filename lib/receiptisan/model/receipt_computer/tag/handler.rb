# frozen_string_literal: true

require 'month'
require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      module Tag
        class Handler
          extend Forwardable

          def initialize(master_loader)
            @master_loader  = master_loader
            @loaded_masters = {}
            @current_master = nil
          end

          # 診療年月にあわせた版のマスタを用意する
          #
          # @param shinryou_ym [Month]
          # @return [void]
          def prepare(shinryou_ym)
            version                    = Receiptisan::Model::ReceiptComputer::Master::Version.resolve_by_ym(shinryou_ym)
            @current_master            = master_loader.load(version)
            @loaded_masters[version] ||= current_master
          end

          # @!parse
          #   # @param tag_key [String, Symbol]
          #   # @return [Tag, nil]
          #   def find_by_key(tag_key); end
          def_delegators :@current_master, :find_by_key

          private

          # @!attribute [r] master_loader
          #   @return [Loader]
          # @!attribute [r] current_master
          #   @return [Master]
          attr_reader :master_loader, :current_master
        end
      end
    end
  end
end
