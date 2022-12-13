# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        # rubocop:disable Metrics/ClassLength
        class Generator
          include Receiptisan::Util::Formatter

          Common             = Receiptisan::Output::Preview::Parameter::Common
          DateUtil           = Receiptisan::Util::DateUtil
          DigitalizedReceipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt
          Tag                = Receiptisan::Model::ReceiptComputer::Tag
          Abbrev             = Receiptisan::Model::ReceiptComputer::Abbrev

          class << self
            # @return [self]
            def create
              new(
                tag_handler:    Tag::Handler.new(Tag::Loader.new),
                abbrev_handler: Abbrev::Handler.new(Abbrev::Loader.new)
              )
            end
          end

          def initialize(tag_handler:, abbrev_handler:)
            @tag_handler                       = tag_handler
            @abbrev_handler                    = abbrev_handler
            @tensuu_shuukei_calculator         = TensuuShuukeiCalculator.new(tag_handler)
            @nyuuinryou_abbrev_label_convertor = NyuuinryouAbbrevLabelConvertor.new(abbrev_handler)
            @byoushou_type_detector            = ByoushouTypeDetector.new(tag_handler)
          end

          # @param digitalized_receipt [DigitalizedReceipt]
          # @return [Common::DigitalizedReceipt]
          def convert_digitalized_receipt(digitalized_receipt)
            parameterized_audit_payer = Common::AuditPayer.from(digitalized_receipt.audit_payer)
            parameterized_hospital    = Common::Hospital.from(digitalized_receipt.hospital)
            parameterized_prefecture  = Common::Prefecture.from(digitalized_receipt.hospital.prefecture)

            Common::DigitalizedReceipt.new(
              seikyuu_ym:  Common::Month.from(digitalized_receipt.seikyuu_ym),
              audit_payer: parameterized_audit_payer,
              hospital:    parameterized_hospital,
              prefecture:  parameterized_prefecture,
              receipts:    []
            ).tap do | parameterized_digitalized_receipt |
              parameterized_digitalized_receipt.receipts = digitalized_receipt.map do | receipt |
                convert_receipt(receipt, parameterized_audit_payer, parameterized_hospital, parameterized_prefecture)
              end
            end
          end

          # @param receipt [DigitalizedReceipt::Receipt]
          # @param parameterized_audit_payer [Common::AuditPayer]
          # @param parameterized_hospital [Common::Hospital]
          # @param parameterized_prefecture [Common::Prefecture]
          # @return [Common::Receipt]
          def convert_receipt(receipt, parameterized_audit_payer, parameterized_hospital, parameterized_prefecture)
            Common::Receipt.new(
              id:                       receipt.id,
              shinryou_ym:              Common::Month.from(receipt.shinryou_ym),
              nyuugai:                  receipt.nyuuin? ? :nyuuin : :gairai,
              audit_payer:              parameterized_audit_payer,
              prefecture:               parameterized_prefecture,
              hospital:                 parameterized_hospital,
              type:                     Common::Type.from(receipt.type),
              tokki_jikous:             receipt.tokki_jikous.values.map { | tj | Common::TokkiJikou.from(tj) },
              patient:                  Common::Patient.from(receipt.patient),
              hokens:                   convert_applied_hoken_list(receipt.hoken_list),
              shoubyoumeis:             convert_shoubyoumeis(receipt.shoubyoumeis),
              tekiyou:                  convert_tekiyou(receipt),
              ryouyou_no_kyuufu:        convert_ryouyou_no_kyuufu(receipt.hoken_list),
              tensuu_shuukei:           convert_tensuu_shuukei(receipt),
              nyuuin_date:              receipt.nyuuin? ? Common::Date.from(receipt.nyuuin_date) : nil,
              byoushou_types:           receipt.nyuuin? ? convert_byoushou_types(receipt)        : nil,
              nyuuinryou_abbrev_labels: convert_nyuuinryou_abbrev_labels(receipt)
            )
          end

          # @param applied_hoken_list [DigitalizedReceipt::Receipt::AppliedHokenList]
          def convert_applied_hoken_list(applied_hoken_list)
            iryou_hoken        = applied_hoken_list.iryou_hoken
            kouhi_futan_iryous = applied_hoken_list.kouhi_futan_iryous
            Common::AppliedHokenList.new(
              iryou_hoken:        iryou_hoken ? Common::IryouHoken.from(iryou_hoken) : nil,
              kouhi_futan_iryous: kouhi_futan_iryous.values.map do | kouhi_futan_iryou |
                Common::KouhiFutanIryou.from(kouhi_futan_iryou)
              end,
              main:               applied_hoken_list.main_order
            )
          end

          # @param applied_hoken_list [DigitalizedReceipt::Receipt::AppliedHokenList]
          def convert_ryouyou_no_kyuufu(applied_hoken_list)
            list = Common::RyouyouNoKyuufuList.new

            if (iryou_hoken = applied_hoken_list.iryou_hoken)
              list.iryou_hoken = Common::RyouyouNoKyuufu.new(
                goukei_tensuu:                           iryou_hoken.goukei_tensuu,
                shinryou_jitsunissuu:                    iryou_hoken.shinryou_jitsunissuu,
                ichibu_futankin:                         iryou_hoken.ichibu_futankin,
                kyuufu_taishou_ichibu_futankin:          iryou_hoken.kyuufu_taishou_ichibu_futankin,
                shokuji_seikatsu_ryouyou_kaisuu:         iryou_hoken.shokuji_seikatsu_ryouyou_kaisuu,
                shokuji_seikatsu_ryouyou_goukei_kingaku: iryou_hoken.shokuji_seikatsu_ryouyou_goukei_kingaku
              )
            end

            list.kouhi_futan_iryous = []
            applied_hoken_list.kouhi_futan_iryous.values.map do | kouhi_futan_iryou |
              list.kouhi_futan_iryous << Common::RyouyouNoKyuufu.new(
                goukei_tensuu:                           kouhi_futan_iryou.goukei_tensuu,
                shinryou_jitsunissuu:                    kouhi_futan_iryou.shinryou_jitsunissuu,
                ichibu_futankin:                         kouhi_futan_iryou.ichibu_futankin,
                kyuufu_taishou_ichibu_futankin:          kouhi_futan_iryou.kyuufu_taishou_ichibu_futankin,
                shokuji_seikatsu_ryouyou_kaisuu:         kouhi_futan_iryou.shokuji_seikatsu_ryouyou_kaisuu,
                shokuji_seikatsu_ryouyou_goukei_kingaku: kouhi_futan_iryou.shokuji_seikatsu_ryouyou_goukei_kingaku
              )
            end

            list
          end

          # @param shoubyoumeis [Array<DigitalizedReceipt::Receipt::Shoubyoumei>]
          # @return [Array<Common::GroupedShoubyoumeiList>]
          def convert_shoubyoumeis(shoubyoumeis)
            sorter = proc do | grouped_list, _ |
              [
                grouped_list.is_main ? 0 : 1,
                grouped_list.start_date.year,
                grouped_list.start_date.month,
                grouped_list.start_date.day,
                grouped_list.tenki.code,
              ]
            end

            # @param shoubyoumei [DigitalizedReceipt::Receipt::Shoubyoumei]
            shoubyoumeis.group_by do | shoubyoumei |
              Common::GroupedShoubyoumeiList.new(
                start_date:   Common::Date.from(shoubyoumei.start_date),
                tenki:        Common::Tenki.from(shoubyoumei.tenki),
                is_main:      shoubyoumei.main?,
                shoubyoumeis: []
              )
              # @param grouped_list [Common::GroupedShoubyoumeiList]
              # @param shoubyoumeis [<DigitalizedReceipt::Receipt::Shoubyoumei>]
            end.sort_by(&sorter).each do | grouped_list, shoubyoumei_list |
              grouped_list.shoubyoumeis = shoubyoumei_list
                .sort_by(&:code)
                .map { | shoubyoumei | Common::Shoubyoumei.from(shoubyoumei) }
            end.to_h.keys
          end

          # @param receipt [DigitalizedReceipt::Receipt]
          def convert_tekiyou(receipt)
            Common::Tekiyou.new(
              shinryou_shikibetsu_sections: receipt.map do | _, ichiren_units |
                Common::ShinryouShikibetsuSection.new(
                  shinryou_shikibetsu: Common::ShinryouShikibetsu.from(ichiren_units.first.shinryou_shikibetsu),
                  ichiren_units:       ichiren_units.map { | ichiren_unit | convert_ichiren_unit(ichiren_unit) }
                )
              end.sort_by { | section | section.shinryou_shikibetsu.code }
            )
          end

          # @param ichiren_unit [DigitalizedReceipt::Receipt::Tekiyou::IchirenUnit]
          # @return [Common::IchirenUnit]
          def convert_ichiren_unit(ichiren_unit)
            Common::IchirenUnit.new(
              futan_kubun:  ichiren_unit.futan_kubun.code,
              santei_units: ichiren_unit.map { | santei_unit | convert_santei_unit(santei_unit) }
            )
          end

          # @param santei_unit [DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit]
          # @return [Common::SanteiUnit]
          def convert_santei_unit(santei_unit)
            parameterized_santei_unit = Common::SanteiUnit.new(
              tensuu: santei_unit.tensuu,
              kaisuu: santei_unit.kaisuu,
              items:  []
            )
            santei_unit.each do | tekiyou_item |
              parameterized_santei_unit.items << convert_tekiyou_item(tekiyou_item)
              next if tekiyou_item.comment?

              tekiyou_item.each_comment do | comment |
                parameterized_santei_unit.items << convert_tekiyou_item(comment)
              end
            end

            parameterized_santei_unit
          end

          # @param tekiyou_item [
          #   DigitalizedReceipt::Receipt::Tekiyou::Cost,
          #   DigitalizedReceipt::Receipt::Tekiyou::Comment
          # ]
          def convert_tekiyou_item(tekiyou_item)
            case tekiyou_item
            when DigitalizedReceipt::Receipt::Tekiyou::Comment
              convert_comment(tekiyou_item)
            else
              resource = tekiyou_item.resource

              Common::Cost.new(
                type:       resource.type,
                master:     {
                  type: resource.type,
                  code: resource.code.value,
                  name: resource.name,
                },
                text:       resource2text(resource),
                unit:       resource.unit&.then { | u | Common::Unit.from(u) },
                shiyouryou: resource.shiyouryou,
                tensuu:     tekiyou_item.tensuu,
                kaisuu:     tekiyou_item.kaisuu
              )
            end
          end

          # @param tekiyou_comment [DigitalizedReceipt::Receipt::Tekiyou::Comment]
          def convert_comment(tekiyou_comment)
            Common::Comment.new(
              type:             :comment,
              master:           Common::MasterComment.new(
                code:    tekiyou_comment.code.value,
                name:    tekiyou_comment.name,
                pattern: tekiyou_comment.pattern.code
              ),
              text:             tekiyou_comment.format,
              appended_content: tekiyou_comment.appended_content&.then do | content |
                Common::AppendedContent.new(text: content.to_s)
              end
            )
          end

          # @return [Common::TensuuShuukei]
          def convert_tensuu_shuukei(receipt)
            tensuu_shuukei_calculator.calculate(receipt)
          end

          def convert_nyuuinryou_abbrev_labels(receipt)
            nyuuinryou_abbrev_label_convertor.convert(receipt)
          end

          # @return [Array<String>]
          def convert_byoushou_types(receipt)
            byoushou_type_detector.detect(receipt)
          end

          # def convert_shokuji_seikatsu_kijun_mark(receipt)
          #   tags['seikatsu-kijun-category-i']
          #   tags['shokuji-kijun-category-i']
          #
          #   ShokujiSeikatsuKijunMark.new()
          # end

          private

          # rubocop:disable Metrics/PerceivedComplexity
          # rubocop:disable Metrics/CyclomaticComplexity
          def resource2text(resource)
            unless (unit = resource.unit)
              return Common::TekiyouText.new(
                master_name:  resource.name,
                product_name: nil,
                unit_price:   nil,
                shiyouryou:   nil
              )
            end

            unit_price = \
              case resource.type
              when :tokutei_kizai
                if resource.unit_price.nil?
                  nil
                else
                  resource.unit_price.to_i == resource.unit_price ?
                    resource.unit_price.to_i :
                    resource.unit_price
                end
              when :iyakuhin, :shinryou_koui
                nil
              end

            shiyouryou = \
              if resource.shiyouryou.nil?
                nil
              else
                resource.shiyouryou.to_i == resource.shiyouryou ?
                  resource.shiyouryou.to_i :
                  resource.shiyouryou
              end

            Common::TekiyouText.new(
              product_name: resource.type == :tokutei_kizai ? resource.product_name : nil,
              master_name:  resource.name,
              unit_price:   unit_price ? '%s円／%s' % [to_zenkaku(unit_price), unit.name] : nil,
              shiyouryou:   shiyouryou ? to_zenkaku(shiyouryou) + unit.name : nil
            )
          end
          # rubocop:enable Metrics/PerceivedComplexity
          # rubocop:enable Metrics/CyclomaticComplexity

          attr_reader :tensuu_shuukei_calculator, :byoushou_type_detector, :nyuuinryou_abbrev_label_convertor
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
