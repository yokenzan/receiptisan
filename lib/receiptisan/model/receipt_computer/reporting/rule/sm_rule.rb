# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          # 160057710 Ｓ−Ｍ 160057510 Ｓ−蛍光Ｍ、位相差Ｍ、暗視野Ｍ の同日算定
          class SMRule
            Util               = Receiptisan::Model::ReceiptComputer::Util
            Master             = Receiptisan::Model::ReceiptComputer::Master
            ShinryouShikibetsu = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu

            def check(digitalized_receipt)
              digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?)
            end

            def check_receipt(receipt)
              code_sm     = Master::Treatment::ShinryouKoui::Code.of('160057710')
              code_keikou = Master::Treatment::ShinryouKoui::Code.of('160057510')

              reports = []

              receipt.each_date do | date, ichirens |
                has_sm     = false
                has_keikou = false

                kensa_ichirens = ichirens[ShinryouShikibetsu.find_by_code(60)]
                kensa_ichirens&.each do | ichiren |
                  ichiren.each do | santei |
                    next unless santei.resource_type == :shinryou_koui

                    santei.each_cost do | cost |
                      has_sm     = true if cost.resource.master_item.code == code_sm
                      has_keikou = true if cost.resource.master_item.code == code_keikou
                    end
                  end
                end

                if has_sm && has_keikou
                  reports << [receipt.audit_payer.short_name, receipt.patient.id, receipt.patient.name, date].join("\t")
                end
              end

              reports
            end
          end
        end
      end
    end
  end
end
