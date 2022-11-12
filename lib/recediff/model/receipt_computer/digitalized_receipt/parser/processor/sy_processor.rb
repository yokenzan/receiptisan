# frozen_string_literal: true

require 'date'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          module Processor
            class SYProcessor
              SY                = DigitalizedReceipt::Record::SY
              Shoubyoumei       = DigitalizedReceipt::Receipt::Shoubyoumei
              MasterShoubyoumei = Master::Diagnose::Shoubyoumei
              MasterShuushokugo = Master::Diagnose::Shuushokugo

              # @param handler [MasterHandler]
              def initialize(handler)
                @handler = handler
              end

              # @param values [Array<String, nil>] SY行
              def process(values)
                raise StandardError, 'line isnt SY record' unless values.first == 'SY'

                process_new_shoubyoumei(values).tap do | shoubyoumei |
                  process_shuushokugo(shoubyoumei, values)
                end
              end

              private

              # @param values [Array<String, nil>]
              # @return [DigitalizedReceipt::Receipt::Shoubyoumei]
              def process_new_shoubyoumei(values)
                Shoubyoumei.new(
                  master_shoubyoumei: handler.find_by_code(
                    MasterShoubyoumei::Code.of(values[SY::C_傷病名コード])
                  ),
                  worpro_name:        values[SY::C_傷病名称],
                  is_main:            values[SY::C_主傷病].to_i == 1,
                  start_date:         Date.parse(values[SY::C_診療開始日]),
                  tenki:              Shoubyoumei::Tenki.find_by_code(values[SY::C_転帰区分]),
                  comment:            values[SY::C_補足コメント]
                )
              end

              # @param shoubyoumei [Shoubyoumei]
              # @param values [Array<String, nil>]
              # @return [void]
              def process_shuushokugo(shoubyoumei, values)
                values[SY::C_修飾語コード]&.scan(/\d{4}/) do | c |
                  shoubyoumei.add_shuushokugo(handler.find_by_code(MasterShuushokugo::Code.of(c)))
                end
              end

              attr_reader :handler
            end
          end
        end
      end
    end
  end
end
