# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          # 特定疾患処方管理加算・特定疾患療養管理料
          class TokuteiShikkanShubyouRule
            Util               = Receiptisan::Model::ReceiptComputer::Util
            Master             = Receiptisan::Model::ReceiptComputer::Master
            ShinryouShikibetsu = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu

            def check(digitalized_receipt)
              append_header(digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?))
            end

            # @param receipt [DigitalizedReceipt::Receipt]
            def check_receipt(receipt)
              reports = []

              shubyous = receipt.shoubyoumeis.select(&:main?)

              receipt.each_date do | date, ichirens |
                next if shubyou_exists?(shubyous, date)

                igaku_kanri_ichirens = ichirens[ShinryouShikibetsu.find_by_code(13)]

                if kanri_cost = pick_kanriryou(igaku_kanri_ichirens || [])
                  reports << [
                    receipt.audit_payer.short_name,
                    receipt.patient.id,
                    receipt.patient.name,
                    date,
                    kanri_cost.resource.code.value,
                    kanri_cost.resource.name,
                  ].join("\t")
                end

                innai_shohou_ichirens = ichirens[ShinryouShikibetsu.find_by_code(25)]

                if kanri_cost = pick_kanri_kasan(innai_shohou_ichirens || [])
                  reports << [
                    receipt.audit_payer.short_name,
                    receipt.patient.id,
                    receipt.patient.name,
                    date,
                    kanri_cost.resource.code.value,
                    kanri_cost.resource.name,
                  ].join("\t")
                end

                ingai_shohou_ichirens = ichirens[ShinryouShikibetsu.find_by_code(80)]

                if kanri_cost = pick_kanri_kasan(ingai_shohou_ichirens || [])
                  reports << [
                    receipt.audit_payer.short_name,
                    receipt.patient.id,
                    receipt.patient.name,
                    date,
                    kanri_cost.resource.code.value,
                    kanri_cost.resource.name,
                  ].join("\t")
                end
              end

              reports
            end

            private

            def append_header(reports)
              header = %w[請求先 患者番号 患者氏名 診療日 診療行為コード 名称].join("\t")

              reports.empty? ? reports : ['主病がない状態で特定疾患療養管理料・特定疾患処方管理加算を算定しているレセプトを検出するルール', header, *reports]
            end

            # @param shubyous [Array<DigitalizedReceipt::Receipt::Shoubyoumei>]
            # @param date [Date]
            def shubyou_exists?(shubyous, date)
              shubyous.any? { | shubyou | shubyou.start_date <= date }
            end

            # @param igaku_kanri_ichirens [Array<DigitalizedReceipt::Receipt::Tekiyou::IchirenUnit>]
            def pick_kanriryou(igaku_kanri_ichirens)
              igaku_kanri_ichirens.each do | ichiren |
                ichiren.each do | santei |
                  next unless santei.resource_type == :shinryou_koui

                  santei.each_cost do | cost |
                    return cost if self.class.kanriryou_codes.include?(cost.resource.code)
                  end
                end
              end

              nil
            end

            # @param shohou_ichirens [Array<DigitalizedReceipt::Receipt::Tekiyou::IchirenUnit>]
            def pick_kanri_kasan(shohou_ichirens)
              shohou_ichirens.each do | ichiren |
                ichiren.each do | santei |
                  next unless santei.resource_type == :shinryou_koui

                  santei.each_cost do | cost |
                    return cost if self.class.kanri_kasan_codes.include?(cost.resource.code)
                  end
                end
              end

              nil
            end

            class << self
              def kanriryou_codes
                [
                  Master::Treatment::ShinryouKoui::Code.of('113001810'),  # 特定疾患療養管理料（診療所）
                  Master::Treatment::ShinryouKoui::Code.of('113001910'),  # 特定疾患療養管理料（１００床未満）
                  Master::Treatment::ShinryouKoui::Code.of('113001910'),  # 特定疾患療養管理料（１００床以上２００床未満）
                  Master::Treatment::ShinryouKoui::Code.of('113029010'),  # 特定疾患療養管理料（情報通信機器）
                  Master::Treatment::ShinryouKoui::Code.of('113034010'),  # 特定疾患療養管理料（診療所・情報通信機器）
                  Master::Treatment::ShinryouKoui::Code.of('113034110'),  # 特定疾患療養管理料（１００床未満の病院・情報通信機器）
                  Master::Treatment::ShinryouKoui::Code.of('113034210'),  # 特定疾患療養管理料（１００床以上２００床未満病院・情報通信機器）
                ]
              end

              def kanri_kasan_codes
                [
                  Master::Treatment::ShinryouKoui::Code.of('120002270'), # 特定疾患処方管理加算１（処方料）
                  Master::Treatment::ShinryouKoui::Code.of('120002570'), # 特定疾患処方管理加算１（処方箋料）
                  Master::Treatment::ShinryouKoui::Code.of('120002570'), # 特定疾患処方管理加算１（処方箋料）
                  Master::Treatment::ShinryouKoui::Code.of('120003170'), # 特定疾患処方管理加算２（処方料）
                  Master::Treatment::ShinryouKoui::Code.of('120003270'), # 特定疾患処方管理加算２（処方箋料）
                  Master::Treatment::ShinryouKoui::Code.of('120003270'), # 特定疾患処方管理加算２（処方箋料）
                ]
              end
            end
          end
        end
      end
    end
  end
end
