# frozen_string_literal: true

require 'month'
require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      module Abbrev
        class Handler
          extend Forwardable

          # @param master_loader [Loader]
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
          #   # @param code [Master::Treatment::ShinryouKoui::Code]
          #   # @return [Array<Abbrev>]
          #   def find_by_code(code); end
          def_delegators :@current_master, :find_by_code

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
