# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          # 薬情月2回以上
          class YakujouRule
            Util   = Receiptisan::Model::ReceiptComputer::Util
            Master = Receiptisan::Model::ReceiptComputer::Master

            def check(digitalized_receipt)
              digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?)
            end

            def check_receipt(receipt)
              return [] if receipt.nyuuin?

              code_yakujou  = Master::Treatment::ShinryouKoui::Code.of('120002370')
              yakujou_count = 0

              Util::ReceiptEnumeratorGenerator.each_cost_for(
                receipt:                   receipt,
                shinryou_shikibetsu_codes: ['13'],
                resource_types:            [:shinryou_koui]
              ).each { | cost | yakujou_count += cost.kaisuu if cost.resource.code == code_yakujou }

              yakujou_count > 1 ?
                [receipt.audit_payer.short_name, receipt.patient.id, receipt.patient.name, yakujou_count].join("\t") :
                []
            end
          end
        end
      end
    end
  end
end
