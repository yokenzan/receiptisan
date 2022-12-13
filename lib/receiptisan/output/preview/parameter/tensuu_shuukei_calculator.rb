# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        # 点数欄の集計
        class TensuuShuukeiCalculator # rubocop:disable Metrics/ClassLength
          include Receiptisan::Output::Preview::Parameter::Common

          DigitalizedReceipt   = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt
          Parameter            = Struct.new(:shinryou_shikibetsu, :target, :grouping, keyword_init: true)

          # 入院 TODO
          @@section_parameter_attributes = {
            '11':                            { shinryou_shikibetsu: %w[11],    target: {} },
            '13':                            { shinryou_shikibetsu: %w[13],    target: {} },
            '14':                            { shinryou_shikibetsu: %w[14],    target: {} },
            '21':                            { shinryou_shikibetsu: %w[21],    target: {} },
            '22':                            { shinryou_shikibetsu: %w[22],    target: {} },
            '23':                            { shinryou_shikibetsu: %w[23],    target: {} },
            '24':                            { shinryou_shikibetsu: %w[24],    target: {} },
            '26':                            { shinryou_shikibetsu: %w[26],    target: {} },
            '27':                            { shinryou_shikibetsu: %w[27],    target: {} },
            '31':                            { shinryou_shikibetsu: %w[31],    target: {} },
            '32':                            { shinryou_shikibetsu: %w[32],    target: {} },
            '33':                            { shinryou_shikibetsu: %w[33],    target: {} },
            '40':                            { shinryou_shikibetsu: %w[40],    target: {} },
            '40_shugi':                      {
              shinryou_shikibetsu: %w[40],
              target:              { resource: %i[shinryou_koui] },
            },
            '40_yakuzai':                    {
              shinryou_shikibetsu: %w[40],
              target:              { resource: %i[iyakuhin tokutei_kizai] },
            },
            '5x':                            { shinryou_shikibetsu: %w[50 54], target: {} },
            '5x_shugi':                      {
              shinryou_shikibetsu: %w[50 54],
              target:              { resource: %i[shinryou_koui] },
            },
            '5x_yakuzai':                    {
              shinryou_shikibetsu: %w[50 54],
              target:              { resource: %i[iyakuhin tokutei_kizai] },
            },
            '60':                            {
              shinryou_shikibetsu: %w[60],
              target:              {},
            },
            '60_shugi':                      {
              shinryou_shikibetsu: %w[60],
              target:              { resource: %i[shinryou_koui] },
            },
            '60_yakuzai':                    {
              shinryou_shikibetsu: %w[60],
              target:              { resource: %i[iyakuhin tokutei_kizai] },
            },
            '70':                            {
              shinryou_shikibetsu: %w[70],
              target:              {},
            },
            '70_shugi':                      {
              shinryou_shikibetsu: %w[70],
              target:              { resource: %i[shinryou_koui] },
            },
            '70_yakuzai':                    {
              shinryou_shikibetsu: %w[70],
              target:              { resource: %i[iyakuhin tokutei_kizai] },
            },
            '80_shugi':                      {
              shinryou_shikibetsu: %w[80],
              target:              { resource: %i[shinryou_koui] },
            },
            '80_yakuzai':                    {
              shinryou_shikibetsu: %w[80],
              target:              { resource: %i[iyakuhin tokutei_kizai] },
            },
            '90':                            { shinryou_shikibetsu: %w[90],    target: {} },
            '92':                            { shinryou_shikibetsu: %w[92],    target: {} },
            '97_shokuji-ryouyou-kijun':      { target: { tag: :'shokuji-ryouyou-kijun' } },
            '97_shokuji-ryouyou-tokubetsu':  { target: { tag: :'shokuji-ryouyou-tokubetsu' } },
            '97_shokuji-ryouyou-shokudou':   { target: { tag: :'shokuji-ryouyou-shokudou' } },
            '97_seikatsu-ryouyou-kankyou':   { target: { tag: :'seikatsu-ryouyou-kankyou' } },
            '97_seikatsu-ryouyou-kijun':     { target: { tag: :'seikatsu-ryouyou-kijun' } },
            '97_seikatsu-ryouyou-tokubetsu': { target: { tag: :'seikatsu-ryouyou-tokubetsu' } },
          }

          # @param handler [Receiptisan::Model::ReceiptComputer::Tag::Handler]
          def initialize(handler)
            @tag_handler = handler
          end

          # @param receipt [DigitalizedReceipt::Receipt]
          # @return [TensuuShuukei]
          def calculate(receipt)
            tag_handler.prepare(receipt.shinryou_ym)

            TensuuShuukei.new(
              sections: @@section_parameter_attributes.to_h do | key, _ |
                [
                  key,
                  TensuuShuukeiSection.new(
                    section: key,
                    hokens:  receipt.hoken_list.each_order.to_h do | order |
                      [
                        order.code,
                        calculate_section(build_parameter(key, order), receipt),
                      ]
                    end
                  ),
                ]
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

            if (tag_key = attributes[:target][:tag])
              # @param tag [TagLoader::Tag]
              tag = tag_handler.find_by_key(tag_key)

              parameter.target << TargetFilter::TagTargetFilter.new(tag)

              parameter.shinryou_shikibetsu = tag.shinryou_shikibetsu if tag.shinryou_shikibetsu
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
              tensuu:       @shuukei_entries.map(&:tensuu).then { | ary | ary.uniq.length == 1 ? ary.first : nil },
              total_kaisuu: @shuukei_entries.map(&:total_kaisuu).sum.then { | sum | sum.zero? ? nil : sum },
              total_tensuu: @shuukei_entries.map(&:total_tensuu).sum.then { | sum | sum.zero? ? nil : sum },
              units:        @shuukei_entries.sort_by(&:total_tensuu).reverse
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

          # @!attribute [r] tag_handler
          #   @return [Tag::Handler]
          attr_reader :tag_handler

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

            # 医療資源のタイプ(診療行為・医薬品・特定器材)で絞込む
            class ResourceTypeTargetFilter
              def initialize(*resource_types)
                @resource_types = resource_types
              end

              # @param santei_unit [DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
              def target?(santei_unit)
                @resource_types.include?(santei_unit.resource_type)
              end
            end

            # タグ(レセ電コードの集合)で絞込む
            class TagTargetFilter
              # @param tag [TagLoader::Tag]
              def initialize(tag)
                @tag = tag
              end

              # @param santei_unit [DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
              def target?(santei_unit)
                santei_unit.each_cost.any? { | cost | @tag.code.include?(cost.resource.code.value) }
              end
            end
          end
        end
      end
    end
  end
end
