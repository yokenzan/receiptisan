# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          # 特別食加算と食事療養数量の不一致を検出するルール
          class TokubetsushokuRule
            Util               = Receiptisan::Model::ReceiptComputer::Util
            Master             = Receiptisan::Model::ReceiptComputer::Master
            ShinryouShikibetsu = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu

            def check(digitalized_receipt)
              append_header(digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?))
            end

            def check_receipt(receipt)
              reports = []

              receipt.each_date do | date, ichirens |

                ichirens = ichirens[ShinryouShikibetsu.find_by_code(97)]
                ichirens&.each do | ichiren |
                  ichiren.each do | santei |
                    next unless santei.resource_type == :shinryou_koui

                    santei.each_cost do | cost |
                      reports << [
                        receipt.audit_payer.short_name,
                        receipt.patient.id,
                        receipt.patient.name,
                        date,
                        cost.resource.code.value,
                        cost.resource.name,
                        '%d食' % cost.resource.shiyouryou,
                      ].join("\t")
                    end
                  end
                end
              end
              reports
            end

            private

            def append_header(reports)
              header = %w[請求先 患者番号 患者氏名 診療日 診療行為コード 名称 食数].join("\t")

              reports.empty? ? reports : ['特別食加算と食事療養数量の不一致を検出するルール', header, *reports]
            end
          end
        end
      end
    end
  end
end
