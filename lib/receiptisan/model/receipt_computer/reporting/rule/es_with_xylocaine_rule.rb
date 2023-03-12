# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          # 内視鏡 × キシロカインゼリー
          class ESWithXylocaineRule
            Util               = Receiptisan::Model::ReceiptComputer::Util
            Master             = Receiptisan::Model::ReceiptComputer::Master
            ShinryouShikibetsu = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu

            def check(digitalized_receipt)
              digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?)
            end

            def check_receipt(receipt)
              code_fs            = Master::Treatment::ShinryouKoui::Code.of('160093810')
              code_poripeku_less = Master::Treatment::ShinryouKoui::Code.of('150285010')
              code_poripeku_more = Master::Treatment::ShinryouKoui::Code.of('150183410')
              code_cs_s          = Master::Treatment::ShinryouKoui::Code.of('160094710')
              code_cs_down_hr    = Master::Treatment::ShinryouKoui::Code.of('160094810')
              code_cs_up         = Master::Treatment::ShinryouKoui::Code.of('160094910')
              code_xylocaine     = Master::Treatment::Iyakuhin::Code.of('620003852')

              code_of_shugis = [
                code_fs,
                code_poripeku_less,
                code_poripeku_more,
                code_cs_s,
                code_cs_down_hr,
                code_cs_up,
              ]

              shinryou_shikibetsu = ShinryouShikibetsu.find_by_code(60)

              reports = []

              receipt.each_date do | date, ichirens |
                shugis               = {}
                xylocaine_shiyouryou = nil

                kensa_ichirens = ichirens[shinryou_shikibetsu]
                kensa_ichirens&.each do | ichiren |
                  ichiren.each do | santei |
                    case santei.resource_type
                    when :shinryou_koui
                      santei.each_cost do | cost |
                        if (code = code_of_shugis.find { | s | s == cost.resource.master_item.code })
                          shugis[code.value] = true
                        end
                      end
                    when :iyakuhin
                      santei.each_cost do | cost |
                        if cost.resource.master_item.code == code_xylocaine
                          xylocaine_shiyouryou = cost.resource.shiyouryou
                        end
                      end
                    end
                  end
                end

                next unless shugis.any? { | _k, v | v == true } && !xylocaine_shiyouryou.nil?

                reports << [
                  receipt.audit_payer.short_name,
                  receipt.nyuuin?,
                  receipt.patient.id,
                  receipt.patient.name,
                  date,
                  shugis[code_fs.value],
                  shugis[code_poripeku_less.value],
                  shugis[code_poripeku_more.value],
                  shugis[code_cs_s.value],
                  shugis[code_cs_down_hr.value],
                  shugis[code_cs_up.value],
                  xylocaine_shiyouryou,
                ].join("\t")
              end

              reports
            end
          end
        end
      end
    end
  end
end
