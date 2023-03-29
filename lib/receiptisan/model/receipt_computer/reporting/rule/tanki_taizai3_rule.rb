# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          # 短期滞在3
          class TankiTaizai3Rule
            Util               = Receiptisan::Model::ReceiptComputer::Util
            Master             = Receiptisan::Model::ReceiptComputer::Master
            ShinryouShikibetsu = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu

            def check(digitalized_receipt)
              append_header(digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?))
            end

            def check_receipt(receipt)
              haihan_codes = [
                Master::Treatment::ShinryouKoui::Code.of('160061810'), # 血液学的検査判断料
                Master::Treatment::ShinryouKoui::Code.of('160061910'), # 生化学的検査（１）判断料
                Master::Treatment::ShinryouKoui::Code.of('160062110'), # 免疫学的検査判断料
                Master::Treatment::ShinryouKoui::Code.of('120001710'), # 調基（入院）
                Master::Treatment::ShinryouKoui::Code.of('120001810'), # 調基（その他）
                Master::Treatment::ShinryouKoui::Code.of('170000210'), # 電子画像管理加算（単純撮影）
                Master::Treatment::ShinryouKoui::Code.of('170016910'), # 電子画像管理加算（特殊撮影）
                Master::Treatment::ShinryouKoui::Code.of('170017010'), # 電子画像管理加算（造影剤使用撮影）
                Master::Treatment::ShinryouKoui::Code.of('170026710'), # 電子画像管理加算（乳房撮影）
                Master::Treatment::ShinryouKoui::Code.of('170026810'), # 電子画像管理加算（核医学診断料）
                Master::Treatment::ShinryouKoui::Code.of('170028810'), # 電子画像管理加算（コンピューター断層診断料）
              ]

              reports = []

              return reports unless tanki3?(receipt)

              Util::ReceiptEnumeratorGenerator.each_cost_for(
                receipt:        receipt,
                resource_types: [:shinryou_koui]
              ).each do | cost |
                haihan_codes.each do | code |
                  cost.resource.code == code && reports << [
                    receipt.audit_payer.short_name,
                    receipt.patient.id,
                    receipt.patient.name,
                    cost.daily_kaisuus.map(&:date).map(&:day).join(', '),
                    code.value,
                    cost.resource.name,
                  ].join("\t")
                end
              end

              reports
            end

            private

            def append_header(reports)
              header = %w[請求先 患者番号 患者氏名 診療日 診療行為コード 診療行為].join("\t")

              reports.empty? ? reports : ['短期滞在手術等基本料に包括される診療行為', header, *reports]
            end

            def tanki3?(receipt)
              has_tanki3 = false

              Util::ReceiptEnumeratorGenerator.each_cost_for(
                receipt:                   receipt,
                shinryou_shikibetsu_codes: ['92'],
                resource_types:            [:shinryou_koui]
              ).each do | cost |
                has_tanki3 = true if cost.resource.name.start_with?('短手３')
              end

              has_tanki3
            end
          end
        end
      end
    end
  end
end
