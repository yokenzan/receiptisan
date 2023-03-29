# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          # メトグルコ錠500mgを1日6錠以上処方するレセプトを抽出する
          class MetglucoRule
            Util               = Receiptisan::Model::ReceiptComputer::Util
            Master             = Receiptisan::Model::ReceiptComputer::Master
            ShinryouShikibetsu = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu

            def check(digitalized_receipt)
              append_header(digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?))
            end

            def check_receipt(receipt)
              metgluco = Master::Treatment::Iyakuhin::Code.of('622242501')

              reports = []

              receipt.each_date do | date, ichirens |

                ichirens = ichirens[ShinryouShikibetsu.find_by_code(21)]
                ichirens&.each do | ichiren |
                  ichiren.each do | santei |
                    next unless santei.resource_type == :iyakuhin

                    santei.each_cost do | cost |
                      if cost.resource.code == metgluco && cost.resource.shiyouryou >= 6
                        reports << [
                          receipt.audit_payer.short_name,
                          receipt.patient.id,
                          receipt.patient.name,
                          date,
                          metgluco.value,
                          cost.resource.name,
                          '%d錠' % cost.resource.shiyouryou,
                        ].join("\t")
                      end
                    end
                  end
                end
              end

              reports
            end

            private

            def append_header(reports)
              header = %w[請求先 患者番号 患者氏名 診療日 医薬品コード 医薬品名 使用量].join("\t")

              reports.empty? ? reports : ['メトグルコ錠の使用量が6錠以上のレセプト', header, *reports]
            end
          end
        end
      end
    end
  end
end
