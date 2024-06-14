# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          class Tokusho2NissuuRule
            Util               = Receiptisan::Model::ReceiptComputer::Util
            Master             = Receiptisan::Model::ReceiptComputer::Master
            ShinryouShikibetsu = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu

            def check(digitalized_receipt)
              append_header(digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?))
            end

            def check_receipt(receipt)
              return [] if receipt.nyuuin?

              reports = []

              shubyous = receipt.shoubyoumeis.select(&:main?)

              receipt.each_date do | date, ichirens |
                # 院内

                innai_shohou_ichirens = ichirens[ShinryouShikibetsu.find_by_code(25)]

                if kanri_cost = pick_kanri_kasan(innai_shohou_ichirens || [])
                  reports << '----------------------------------------'
                  reports << receipt.audit_payer.short_name
                  reports << [receipt.patient.id, receipt.patient.name]
                  reports << [date, kanri_cost.resource.name, kanri_cost.resource.code.value].join("\t")
                end

                # 院外

                ingai_shohou_ichirens = ichirens[ShinryouShikibetsu.find_by_code(80)]

                if kanri_cost_ingai = pick_kanri_kasan(ingai_shohou_ichirens || [])
                  reports << '----------------------------------------'
                  reports << receipt.audit_payer.short_name
                  reports << receipt.patient.id
                  reports << receipt.patient.name
                  reports << [date, kanri_cost_ingai.resource.name, kanri_cost_ingai.resource.code.value].join("\t")
                end

                next if kanri_cost.nil? && kanri_cost_ingai.nil?

                yakuzais = []
                naifuku_ichirens = ichirens[ShinryouShikibetsu.find_by_code(21)]

                naifuku_ichirens&.each do | ichiren |
                  ichiren.each do | santei |
                    next unless santei.resource_type == :iyakuhin

                    santei_kaisuuu_suuryou = ''
                    santei.each.with_index do | cost, idx |
                      prefix = idx.zero? ? '＊' : '　'
                      if cost.comment?
                        yakuzais << "#{prefix}\t#{cost.format}"
                      else
                        yakuzais << "%s\t%s %d%s" % [
                          prefix,
                          cost.resource.name,
                          cost.resource.shiyouryou || 0,
                          cost.resource.unit&.name || '',
                        ]

                        santei_kaisuuu_suuryou = "\t%d x %d" % [santei.tensuu, santei.kaisuu]
                      end

                      yakuzais << santei_kaisuuu_suuryou unless santei_kaisuuu_suuryou.empty?
                    end
                  end
                end

                reports << yakuzais
              end

              reports
            end

            private

            def append_header(reports)
              header = %w[患者番号 患者氏名 診療日].join("\t")

              reports.empty? ? reports : ['内服他剤の可能性がある患者リスト', header, *reports]
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
              def kanri_kasan_codes
                [
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
