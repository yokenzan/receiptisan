# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      module Reporting
        module Rule
          class NaifukuTazaiRule
            Util               = Receiptisan::Model::ReceiptComputer::Util
            Master             = Receiptisan::Model::ReceiptComputer::Master
            ShinryouShikibetsu = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::ShinryouShikibetsu

            def check(digitalized_receipt)
              digitalized_receipt.map { | receipt | check_receipt(receipt) }.reject(&:empty?)
            end

            def check_receipt(receipt)
              return [] if receipt.nyuuin?

              reports = []

              receipt.each_date do | date, ichirens |
                count = 0
                is_teigened = false
                yakuzais = []
                naifuku_ichirens = ichirens[ShinryouShikibetsu.find_by_code(21)]
                naifuku_ichirens&.each do | ichiren |
                  ichiren.each do | santei |
                    next unless santei.resource_type == :iyakuhin

                    santei_kaisuuu_suuryou = ''
                    santei.each.with_index do | cost, idx |
                      prefix = idx.zero? ? '＊' : '　'
                      if cost.comment?
                        yakuzais << "#{prefix}#{cost.format}"
                      else
                        yakuzais << '%s%s %d%s' % [prefix, cost.resource.master_item.name, cost.resource.shiyouryou,
                                                   cost.resource.unit&.name,]
                        isnt_teigen = cost.resource.master_item.code != Master::Treatment::Iyakuhin::Code.of('630010002')
                        is_iyakuhin = cost.resource_type == :iyakuhin
                        is_teigened = true unless isnt_teigen
                        count += 1 if is_iyakuhin && isnt_teigen

                        santei_kaisuuu_suuryou = "\t%d x %d" % [santei.tensuu, santei.kaisuu]
                      end

                      yakuzais << santei_kaisuuu_suuryou unless santei_kaisuuu_suuryou.empty?
                    end
                  end
                end

                return [] if is_teigened || count < 7

                result = [
                  '-' * 50,
                  '%s%s - %s日' % [receipt.patient.id, receipt.patient.name, date.day]
                ] + yakuzais

                reports << result
              end

              reports
            end
          end
        end
      end
    end
  end
end
