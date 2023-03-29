# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          # 同日にＳＡＲＳ−ＣｏＶ−２・インフルエンザウイルス抗原同時検出（定性）とインフルエンザウイルス抗原定性又は
          # ＳＡＲＳ−ＣｏＶ−２抗原検出が算定されています。別に算定できないと定められていますのでご留意願います。
          class InfluenzaRule
            Util               = Receiptisan::Model::ReceiptComputer::Util
            Master             = Receiptisan::Model::ReceiptComputer::Master
            ShinryouShikibetsu = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu

            def check(digitalized_receipt)
              append_header(digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?))
            end

            def check_receipt(receipt)
              code_of_インフルエンザウイルス抗原定性 = Master::Treatment::ShinryouKoui::Code.of('160169450')
              code_of_ＳＡＲＳ_ＣｏＶ_２抗原検出（定性）                     = Master::Treatment::ShinryouKoui::Code.of('160229850')
              code_of_ＳＡＲＳ_ＣｏＶ_２抗原検出（定量）                     = Master::Treatment::ShinryouKoui::Code.of('160229950')
              code_of_ＳＡＲＳ_ＣｏＶ_２・インフルエンザウイルス抗原同時検出 = Master::Treatment::ShinryouKoui::Code.of('160230050')

              reports = []

              receipt.each_date do | date, ichirens |
                has_インフルエンザウイルス抗原定性 = false
                has_ＳＡＲＳ_ＣｏＶ_２抗原検出 = false
                has_ＳＡＲＳ_ＣｏＶ_２・インフルエンザウイルス抗原同時検出 = false

                kensa_ichirens = ichirens[ShinryouShikibetsu.find_by_code(60)]
                kensa_ichirens&.each do | ichiren |
                  ichiren.each do | santei |
                    next unless santei.resource_type == :shinryou_koui

                    santei.each_cost do | cost |
                      has_インフルエンザウイルス抗原定性 = true if code_of_インフルエンザウイルス抗原定性 == cost.resource.master_item.code
                      has_ＳＡＲＳ_ＣｏＶ_２抗原検出 = true if code_of_ＳＡＲＳ_ＣｏＶ_２抗原検出（定量） == cost.resource.master_item.code
                      has_ＳＡＲＳ_ＣｏＶ_２抗原検出 = true if code_of_ＳＡＲＳ_ＣｏＶ_２抗原検出（定性） == cost.resource.master_item.code
                      if code_of_ＳＡＲＳ_ＣｏＶ_２・インフルエンザウイルス抗原同時検出 == cost.resource.master_item.code
                        has_ＳＡＲＳ_ＣｏＶ_２・インフルエンザウイルス抗原同時検出 = true
                      end
                    end
                  end
                end

                hass = [
                  has_インフルエンザウイルス抗原定性,
                  has_ＳＡＲＳ_ＣｏＶ_２抗原検出,
                  has_ＳＡＲＳ_ＣｏＶ_２・インフルエンザウイルス抗原同時検出,
                ]

                if hass.select { | a | a == true }.length > 1
                  reports << [
                    receipt.audit_payer.short_name,
                    receipt.patient.id,
                    receipt.patient.name,
                    date
                  ].join("\t")
                end
              end

              reports
            end

            private

            def append_header(reports)
              header = %w[請求先 患者番号 患者氏名 診療日].join("\t")

              reports.empty? ? reports : ['インフルエンザ系検査併算定', header, *reports]
            end
          end
        end
      end
    end
  end
end
