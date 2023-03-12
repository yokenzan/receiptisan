# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          # ジメチコン × 胃カメラなし
          class DimethiconeRule
            Util   = Receiptisan::Model::ReceiptComputer::Util
            Master = Receiptisan::Model::ReceiptComputer::Master

            def check(digitalized_receipt)
              digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?)
            end

            def check_receipt(receipt)
              # | 620422003 | ジメチコン錠４０ｍｇ「ＹＤ」   |
              # | 620423501 | ジメチコン内用液２％「ＦＳＫ」 |
              code_fs             = Master::Treatment::ShinryouKoui::Code.of('160093810')
              code_of_dimechicones = [
                Master::Treatment::Iyakuhin::Code.of('620422003'),
                Master::Treatment::Iyakuhin::Code.of('620423501'),
              ]

              has_fs          = false
              used_dimechicone = nil

              Util::ReceiptEnumeratorGenerator.each_cost_for(
                receipt:        receipt,
                resource_types: %i[shinryou_koui iyakuhin]
              ).each do | cost |
                case cost.resource_type
                when :shinryou_koui
                  has_fs = true if cost.resource.code == code_fs
                when :iyakuhin
                  used_dimechicone = cost.resource if code_of_dimechicones.any? { | c | c == cost.resource.code }
                end
              end

              return '' if has_fs || used_dimechicone.nil?

              [
                receipt.audit_payer.short_name,
                receipt.patient.id,
                receipt.patient.name,
                used_dimechicone.code.value,
                used_dimechicone.name,
                '%s%s' % [used_dimechicone.shiyouryou, used_dimechicone.unit.name],
              ].join("\t")
            end
          end
        end
      end
    end
  end
end
