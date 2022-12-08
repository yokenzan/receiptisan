# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Resource
              class Iyakuhin
                extend Forwardable
                Formatter = Receiptisan::Util::Formatter

                def initialize(master_item:, shiyouryou:)
                  @master_item = master_item
                  @shiyouryou  = shiyouryou
                end

                def type
                  :iyakuhin
                end

                # @!attribute [r] master_item
                #   @return [Master::Treatment::Iyakuhin]
                # @!attribute [r] shiyouryou
                #   @return [Float, nil]
                attr_reader :master_item, :shiyouryou

                # @!attribute [r] code
                #   @return [Master::Treatment::Iyakuhin::Code]
                # @!attribute [r] name
                #   @return [String]
                # @!attribute [r] unit
                #   @return [Master::Unit, nil]
                def_delegators :master_item, :code, :name, :unit

                class << self
                  # @return [self]
                  def dummy(shiyouryou:, code:)
                    new(master_item: DummyMasterIyakuhin.new(code), shiyouryou: shiyouryou)
                  end
                end

                # マスタに医薬品コードが見つからなかった医薬品
                DummyMasterIyakuhin = Struct.new(:code) do
                  # @return [String]
                  def name
                    Formatter.to_zenkaku '【不明な医薬品：%s】' % code.value
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
