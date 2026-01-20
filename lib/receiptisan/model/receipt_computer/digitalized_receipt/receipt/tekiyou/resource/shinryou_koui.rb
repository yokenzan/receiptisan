# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Resource
              class ShinryouKoui
                extend Forwardable

                Formatter = Receiptisan::Util::Formatter

                def initialize(master_item:, shiyouryou:)
                  @master_item = master_item
                  @shiyouryou  = shiyouryou
                end

                def type
                  :shinryou_koui
                end

                # @!attribute [r] master_item
                #   @return [Master::Treatment::ShinryouKoui]
                # @!attribute [r] shiyouryou
                #   @return [Integer, nil]
                attr_reader :master_item, :shiyouryou

                # @!attribute [r] code
                #   @return [Master::Treatment::ShinryouKoui::Code]
                # @!attribute [r] name
                #   @return [String]
                # @!attribute [r] unit
                #   @return [Master::Unit, nil]
                def_delegators :master_item, :code, :name, :unit

                class << self
                  # @return [self]
                  def dummy(shiyouryou:, code:)
                    new(master_item: DummyMasterShinryouKoui.new(code), shiyouryou: shiyouryou)
                  end
                end

                # マスタに診療行為コードが見つからなかった診療行為
                DummyMasterShinryouKoui = Struct.new(:code) do
                  # @return [String]
                  def name
                    Formatter.to_zenkaku '【不明な診療行為：%s】' % code.value
                  end

                  # @return [nil]
                  def unit
                    nil
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
