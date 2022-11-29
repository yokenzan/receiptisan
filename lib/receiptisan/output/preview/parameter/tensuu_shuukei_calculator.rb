# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        module Common
          # 点数欄の集計
          class TensuuShuukeiCalculator
            DigitalizedReceipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt
            Parameter          = Struct.new(:shinryou_shikibetsu, :target, :grouping, keyword_init: true)

            # 入院
            @@section_parameter_attributes = {
              '11':         { shinryou_shikibetsu: %w[11],    target: {} },
              '13':         { shinryou_shikibetsu: %w[13],    target: {} },
              '14':         { shinryou_shikibetsu: %w[14],    target: {} },
              '21':         { shinryou_shikibetsu: %w[21],    target: {} },
              '22':         { shinryou_shikibetsu: %w[22],    target: {} },
              '23':         { shinryou_shikibetsu: %w[23],    target: {} },
              '24':         { shinryou_shikibetsu: %w[24],    target: {} },
              '26':         { shinryou_shikibetsu: %w[26],    target: {} },
              '27':         { shinryou_shikibetsu: %w[27],    target: {} },
              '31':         { shinryou_shikibetsu: %w[31],    target: {} },
              '32':         { shinryou_shikibetsu: %w[32],    target: {} },
              '33':         { shinryou_shikibetsu: %w[33],    target: {} },
              '40':         { shinryou_shikibetsu: %w[40],    target: {} },
              '40_shugi':   { shinryou_shikibetsu: %w[40],    target: { resource: %i[shinryou_koui] } },
              '40_yakuzai': { shinryou_shikibetsu: %w[40],    target: { resource: %i[iyakuhin tokutei_kizai] } },
              '5x':         { shinryou_shikibetsu: %w[50 54], target: {} },
              '5x_shugi':   { shinryou_shikibetsu: %w[50 54], target: { resource: %i[shinryou_koui] } },
              '5x_yakuzai': { shinryou_shikibetsu: %w[50 54], target: { resource: %i[iyakuhin tokutei_kizai] } },
              '60':         { shinryou_shikibetsu: %w[60],    target: {} },
              '60_shugi':   { shinryou_shikibetsu: %w[60],    target: { resource: %i[shinryou_koui] } },
              '60_yakuzai': { shinryou_shikibetsu: %w[60],    target: { resource: %i[iyakuhin tokutei_kizai] } },
              '70':         { shinryou_shikibetsu: %w[70],    target: {} },
              '70_shugi':   { shinryou_shikibetsu: %w[70],    target: { resource: %i[shinryou_koui] } },
              '70_yakuzai': { shinryou_shikibetsu: %w[70],    target: { resource: %i[iyakuhin tokutei_kizai] } },
              '80_shugi':   { shinryou_shikibetsu: %w[80],    target: { resource: %i[shinryou_koui] } },
              '80_yakuzai': { shinryou_shikibetsu: %w[80],    target: { resource: %i[iyakuhin tokutei_kizai] } },
              '90':         { shinryou_shikibetsu: %w[90],    target: {} },
              '92':         { shinryou_shikibetsu: %w[92],    target: {} },
            }

            # @param receipt [DigitalizedReceipt::Receipt]
            # @return [TensuuShuukei]
            def calculate(receipt)
              hoken_orders = receipt.hoken_list.to_hoken_orders

              TensuuShuukei.new(
                sections: @@section_parameter_attributes.map do | key, _ |
                  TensuuShuukeiSection.new(
                    section: key,
                    hokens:  hoken_orders.map do | order | # rubocop:disable Style/MapToHash
                      [
                        order.code,
                        calculate_section(build_parameter(key, order), receipt),
                      ]
                    end.to_h
                  )
                end
              )
            end

            private

            def build_parameter(key, order)
              attributes = @@section_parameter_attributes[key]

              parameter = Parameter.new(
                shinryou_shikibetsu: attributes[:shinryou_shikibetsu],
                target:              [],
                grouping:            []
              )

              if (resources = attributes[:target][:resource])
                parameter.target << TargetFilter::ResourceTypeTargetFilter.new(*resources)
              end

              if (lists = attributes[:target][:list])
                lists.each { | list | parameter.target << TargetFilter::ListTargetFilter.build(list) }
              end

              parameter.target << TargetFilter::HokenOrderTargetFilter.new(order)

              parameter
            end

            # @param receipt [DigitalizedReceipt::Receipt]
            def calculate_section(parameter, receipt)
              @shuukei_entries = []
              @parameter       = parameter

              @parameter.shinryou_shikibetsu.each do | shinryou_shikibetsu |
                # @param ichiren [DigitalizedReceipt::Receipt::Tekiyou::IchirenUnit]
                (receipt[shinryou_shikibetsu] || []).each do | ichiren |
                  ichiren.each { | santei_unit | each_santei_unit(santei_unit) }
                end
              end

              combine_units
            end

            def combine_units
              CombinedTensuuShuukeiUnit.new(
                tensuu:       (tensuu = @shuukei_entries.map(&:tensuu).uniq.length == 1) ? tensuu : nil,
                total_kaisuu: @shuukei_entries.map(&:total_kaisuu).sum,
                total_tensuu: @shuukei_entries.map(&:total_tensuu).sum,
                units:        @shuukei_entries
              )
            end

            # @param santei_unit [DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
            def each_santei_unit(santei_unit)
              return unless santei_unit.calculate
              return unless @parameter.target.all? { | filter | filter.target?(santei_unit) }

              shuukei_unit = find_by_tensuu_or_new(santei_unit.tensuu)

              shuukei_unit.total_tensuu += santei_unit.calculate
              shuukei_unit.total_kaisuu += santei_unit.kaisuu
            end

            # @return [TensuuShuukeiUnit]
            def find_by_tensuu_or_new(tensuu)
              if (detected = @shuukei_entries.find { | entry | entry.tensuu == tensuu })
                return detected
              end

              new_unit.tap do | unit |
                @shuukei_entries << unit
                unit.tensuu = tensuu
              end
            end

            def new_unit
              TensuuShuukeiUnit.new(
                tensuu:       nil,
                total_kaisuu: 0,
                total_tensuu: 0
              )
            end

            # 集計対象とする算定単位の絞込条件
            module TargetFilter
              class HokenOrderTargetFilter
                def initialize(hoken_order)
                  @hoken_order = hoken_order
                end

                # @param santei_unit [DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
                def target?(santei_unit)
                  santei_unit.uses?(@hoken_order)
                end
              end

              class ResourceTypeTargetFilter
                def initialize(*resource_types)
                  @resource_types = resource_types
                end

                # @param santei_unit [DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
                def target?(santei_unit)
                  @resource_types.include?(santei_unit.resource_type)
                end
              end

              # unused
              class ListTargetFilter
                def initialize(*master_codes)
                  @master_codes = master_codes
                end

                # @param santei_unit [DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
                def target?(santei_unit)
                  santei_unit.each_cost.any? { | cost | @master_codes.include?(cost.resource.code.value) }
                end
              end
            end
          end
        end
      end
    end
  end
end
