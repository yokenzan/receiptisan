# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            class Resource
              class TokuteiKizai
                extend Forwardable
                Formatter = Receiptisan::Util::Formatter

                def initialize(
                  master_item:,
                  shiyouryou:,
                  product_name:,
                  unit:,
                  unit_price:
                )
                  @master_item  = master_item
                  @shiyouryou   = shiyouryou
                  @product_name = product_name
                  @unit         = unit
                  @unit_price   = unit_price
                end

                def type
                  :tokutei_kizai
                end

                # @return [Master::Unit, nil]
                def unit
                  @unit || master_item.unit
                end

                # @return [Float, nil]
                def unit_price
                  @unit_price || master_item.price
                end

                # @!attribute [r] master_item
                #   @return [Master::Treatment::TokuteiKizai]
                # @!attribute [r] shiyouryou
                #   @return [Float, nil]
                # @!attribute [r] product_name
                #   @return [String, nil]
                attr_reader :master_item, :shiyouryou, :product_name

                # @!attribute [r] code
                #   @return [Master::Treatment::TokuteiKizai::Code]
                # @!attribute [r] name
                #   @return [String]
                def_delegators :master_item, :code, :name, :price_type

                class << self
                  # @return [self]
                  def dummy(code:, shiyouryou:, product_name:, unit:, unit_price:)
                    new(
                      master_item:  DummyMasterTokuteiKizai.new(code),
                      shiyouryou:   shiyouryou,
                      product_name: product_name,
                      unit:         unit,
                      unit_price:   unit_price
                    )
                  end
                end

                # マスタに医薬品コードが見つからなかった医薬品
                DummyMasterTokuteiKizai = Struct.new(:code) do
                  # @return [String]
                  def name
                    Formatter.to_zenkaku '【不明な特定器材：%s】' % code.value
                  end

                  # @return [nil]
                  def unit
                    nil
                  end

                  def unit_price
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
