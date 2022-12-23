# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        class Generator
          class TekiyouConvertor
            class ResourceTextConvertor
              Common    = Receiptisan::Output::Preview::Parameter::Common
              Formatter = Receiptisan::Util::Formatter

              # @return [Common::TekiyouText]
              def convert(resource)
                Common::TekiyouText.new(
                  product_name: convert_product_name(resource),
                  master_name:  convert_name(resource),
                  unit_price:   convert_unit_price(resource),
                  shiyouryou:   convert_shiyouryou(resource)
                )
              end

              # @return [String]
              def convert_name(resource)
                resource.name
              end

              # @return [String, nil]
              def convert_product_name(resource)
                resource.type == :tokutei_kizai ? resource.product_name : nil
              end

              # @return [String, nil]
              def convert_unit_price(resource)
                return unless resource.type == :tokutei_kizai

                resource.unit_price&.then do | unit_price |
                  '%s円／%s' % [
                    Formatter.to_zenkaku(unit_price.to_i == unit_price ? unit_price.to_i : unit_price),
                    resource.unit&.name, # 酸素補正率は単位がない
                  ]
                end
              end

              # @return [String, nil]
              def convert_shiyouryou(resource)
                resource.shiyouryou&.then do | shiyouryou |
                  '%s%s' % [
                    Formatter.to_zenkaku(shiyouryou.to_i == shiyouryou ? shiyouryou.to_i : shiyouryou),
                    resource.unit.name,
                  ]
                end
              end
            end
          end
        end
      end
    end
  end
end
