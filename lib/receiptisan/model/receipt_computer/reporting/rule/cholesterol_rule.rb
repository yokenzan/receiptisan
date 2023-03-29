# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          # コレステロール
          class CholesterolRule
            Util               = Receiptisan::Model::ReceiptComputer::Util
            Master             = Receiptisan::Model::ReceiptComputer::Master
            ShinryouShikibetsu = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu

            def check(digitalized_receipt)
              append_header(digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?))
            end

            def check_receipt(receipt)
              tcho = Master::Treatment::ShinryouKoui::Code.of('160022410')
              ldl = Master::Treatment::ShinryouKoui::Code.of('160167250')
              hdl = Master::Treatment::ShinryouKoui::Code.of('160023410')

              reports = []

              receipt.each_date do | date, ichirens |
                has_tcho = false
                has_ldl  = false
                has_hdl  = false

                kensa_ichirens = ichirens[ShinryouShikibetsu.find_by_code(60)]
                kensa_ichirens&.each do | ichiren |
                  ichiren.each do | santei |
                    next unless santei.resource_type == :shinryou_koui

                    santei.each_cost do | cost |
                      has_tcho = true if cost.resource.master_item.code == tcho
                      has_ldl  = true if cost.resource.master_item.code == ldl
                      has_hdl  = true if cost.resource.master_item.code == hdl
                    end
                  end
                end

                if has_tcho && has_hdl && has_ldl
                  reports << [receipt.audit_payer.short_name, receipt.patient.id, receipt.patient.name, date].join("\t")
                end
              end

              reports
            end

            private

            def append_header(reports)
              header = %w[請求先 患者番号 患者氏名 診療日].join("\t")

              reports.empty? ? reports : ['コレステロール検査同日併算定', header, *reports]
            end
          end
        end
      end
    end
  end
end
