# frozen_string_literal: true

require_relative 'generator/shoubyoumei_group_convertor'
require_relative 'generator/tekiyou_convertor'
require_relative 'generator/convertor_provider'

module Receiptisan
  module Output
    module Preview
      module Parameter
        # rubocop:disable Metrics/ClassLength
        class Generator
          include Receiptisan::Util::Formatter

          Common             = Receiptisan::Output::Preview::Parameter::Common
          DigitalizedReceipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt
          HokenOrder         = DigitalizedReceipt::Receipt::FutanKubun::HokenOrder
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
            @tensuu_shuukei_calculator         = TensuuShuukeiCalculator.new(tag_handler)
            @kijun_mark_detector               = KijunMarkDetector.new(tag_handler)
            @hyoujun_futangaku_calculator      = HyoujunFutangakuCalculator.new(tag_handler)

            @abbrev_handler                    = abbrev_handler
            @nyuuinryou_abbrev_label_convertor = NyuuinryouAbbrevLabelConvertor.new(abbrev_handler)
            @shoubyoumei_group_convertor       = Generator::ShoubyoumeiGroupConvertor.new
            @tekiyou_convertor                 = ConvertorProvider.provide
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
                convert_receipt(
                  receipt:                   receipt,
                  parameterized_audit_payer: parameterized_audit_payer,
                  parameterized_hospital:    parameterized_hospital,
                  parameterized_prefecture:  parameterized_prefecture
                )
              end
            end
          end

          # @param receipt [DigitalizedReceipt::Receipt]
          # @param parameterized_audit_payer [Common::AuditPayer]
          # @param parameterized_hospital [Common::Hospital]
          # @param parameterized_prefecture [Common::Prefecture]
          # @return [Common::Receipt]
          def convert_receipt(
            receipt:,
            parameterized_audit_payer:,
            parameterized_hospital:,
            parameterized_prefecture:
          )
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
              classification:           receipt.type.classification,
              shoubyoumeis:             @shoubyoumei_group_convertor.convert(receipt.shoubyoumeis),
              tekiyou:                  @tekiyou_convertor.convert(receipt),
              ryouyou_no_kyuufu:        convert_ryouyou_no_kyuufu(receipt),
              tensuu_shuukei:           convert_tensuu_shuukei(receipt),
              nyuuin_date:              receipt.nyuuin? ? Common::Date.from(receipt.nyuuin_date) : nil,
              kijun_marks:              receipt.nyuuin? ? convert_kijun_marks(receipt)           : nil,
              byoushou_types:           convert_byoushou_types(receipt),
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

          # TODO: HokenOrderをちゃんと使う
          #
          # @param receipt [DigitalizedReceipt::Receipt]
          def convert_ryouyou_no_kyuufu(receipt)
            applied_hoken_list = receipt.hoken_list
            ryouyou_no_kyuufu  = Common::RyouyouNoKyuufuList.new
            hyoujun_futangakus = hyoujun_futangaku_calculator.calculate(receipt)

            if (iryou_hoken = applied_hoken_list.iryou_hoken)
              ryouyou_no_kyuufu.iryou_hoken = Common::RyouyouNoKyuufu.new(
                goukei_tensuu:                              iryou_hoken.goukei_tensuu,
                shinryou_jitsunissuu:                       iryou_hoken.shinryou_jitsunissuu,
                ichibu_futankin:                            iryou_hoken.ichibu_futankin,
                kyuufu_taishou_ichibu_futankin:             iryou_hoken.kyuufu_taishou_ichibu_futankin,
                shokuji_seikatsu_ryouyou_kaisuu:            iryou_hoken.shokuji_seikatsu_ryouyou_kaisuu,
                shokuji_seikatsu_ryouyou_goukei_kingaku:    iryou_hoken.shokuji_seikatsu_ryouyou_goukei_kingaku,
                shokuji_seikatsu_ryouyou_hyoujun_futangaku: hyoujun_futangakus[HokenOrder::HOKEN_ORDER_IRYOU_HOKEN]
              )
            end

            ryouyou_no_kyuufu.kouhi_futan_iryous = []
            applied_hoken_list.kouhi_futan_iryous.values.map.with_index do | kouhi_futan_iryou, index |
              ryouyou_no_kyuufu.kouhi_futan_iryous << Common::RyouyouNoKyuufu.new(
                goukei_tensuu:                              kouhi_futan_iryou.goukei_tensuu,
                shinryou_jitsunissuu:                       kouhi_futan_iryou.shinryou_jitsunissuu,
                ichibu_futankin:                            kouhi_futan_iryou.ichibu_futankin,
                kyuufu_taishou_ichibu_futankin:             kouhi_futan_iryou.kyuufu_taishou_ichibu_futankin,
                shokuji_seikatsu_ryouyou_kaisuu:            kouhi_futan_iryou.shokuji_seikatsu_ryouyou_kaisuu,
                shokuji_seikatsu_ryouyou_goukei_kingaku:    kouhi_futan_iryou.shokuji_seikatsu_ryouyou_goukei_kingaku,
                shokuji_seikatsu_ryouyou_hyoujun_futangaku: hyoujun_futangakus[HokenOrder.kouhi_futan_iryou(index).code]
              )
            end

            ryouyou_no_kyuufu
          end

          # @return [Common::TensuuShuukei]
          def convert_tensuu_shuukei(receipt)
            tensuu_shuukei_calculator.calculate(receipt)
          end

          def convert_nyuuinryou_abbrev_labels(receipt)
            nyuuinryou_abbrev_label_convertor.convert(receipt)
          end

          # @return [Array<Common::ByoushouType>]
          def convert_byoushou_types(receipt)
            receipt.byoushou_types.map { | byoushou_type | Common::ByoushouType.from(byoushou_type) }
          end

          def convert_kijun_marks(receipt)
            kijun_mark_detector.detect(receipt)
          end

          private

          attr_reader :tensuu_shuukei_calculator,
            :kijun_mark_detector,
            :nyuuinryou_abbrev_label_convertor,
            :hyoujun_futangaku_calculator
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
