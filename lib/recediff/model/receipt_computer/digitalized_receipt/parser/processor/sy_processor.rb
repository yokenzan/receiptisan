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
              MasterShoubyoumei = Master::Diagnosis::Shoubyoumei
              MasterShuushokugo = Master::Diagnosis::Shuushokugo

              # @param handler [MasterHandler]
              def initialize(handler)
                @handler = handler
              end

              # @param values [Array<String, nil>] SY行
              def process(values)
                raise StandardError, 'line isnt SY record' unless values.first == 'SY'

                process_new_shoubyoumei(values).tap do | shoubyoumei |
                  process_shuushokugos(values[SY::C_修飾語コード]) { | shuushokugo | shoubyoumei.add_shuushokugo(shuushokugo) }
                end
              end

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

              # @param combined_values_of_code [String, nil]
              # @return [Array<Master::Diagnosis::Shuushokugo>]
              def process_shuushokugos(combined_values_of_code)
                return [] unless combined_values_of_code

                combined_values_of_code.scan(/\d{4}/).map { | c | process_shuushokugo(c) }
              end

              private

              def process_shuushokugo(value_of_code)
                handler.find_by_code(MasterShuushokugo::Code.of(value_of_code))
              end

              attr_reader :handler
            end
          end
        end
      end
    end
  end
end
