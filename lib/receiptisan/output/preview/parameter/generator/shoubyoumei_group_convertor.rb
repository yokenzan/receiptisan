# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module Parameter
        class Generator
          class ShoubyoumeiGroupConvertor
            include Receiptisan::Util::Formatter
            Common             = Receiptisan::Output::Preview::Parameter::Common
            DigitalizedReceipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt

            @@sorter = proc do | grouped_list, _ |
              [
                grouped_list.is_main ? 0 : 1,
                grouped_list.start_date.year,
                grouped_list.start_date.month,
                grouped_list.start_date.day,
                grouped_list.tenki.code,
              ]
            end

            # @param shoubyoumeis [Array<DigitalizedReceipt::Receipt::Shoubyoumei>]
            # @return [Array<Common::GroupedShoubyoumeiList>]
            def convert(shoubyoumeis)
              # @param shoubyoumei [DigitalizedReceipt::Receipt::Shoubyoumei]
              shoubyoumeis.group_by do | shoubyoumei |
                Common::GroupedShoubyoumeiList.new(
                  start_date:   Common::Date.from(shoubyoumei.start_date),
                  tenki:        Common::Tenki.from(shoubyoumei.tenki),
                  is_main:      shoubyoumei.main?,
                  shoubyoumeis: []
                )
                # @param grouped_list [Common::GroupedShoubyoumeiList]
                # @param shoubyoumeis [<DigitalizedReceipt::Receipt::Shoubyoumei>]
              end.sort_by(&@@sorter).each do | grouped_list, shoubyoumei_list |
                grouped_list.shoubyoumeis = shoubyoumei_list
                  .sort_by(&:code)
                  .map { | shoubyoumei | Common::Shoubyoumei.from(shoubyoumei) }
              end.to_h.keys
            end
          end
        end
      end
    end
  end
end
