# frozen_string_literal: true

require 'forwardable'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          class Shoubyoumei
            include Receiptisan::Model::ReceiptComputer
            extend Forwardable
            Formatter = Receiptisan::Util::Formatter

            WORPRO_SHOUBYOUMEI_CODE = ReceiptComputer::Master::Diagnosis::Shoubyoumei::Code.of('0000999')

            def initialize(master_shoubyoumei:, worpro_name:, is_main:, start_date:, tenki:, comment:)
              @master_shoubyoumei  = master_shoubyoumei
              @worpro_name         = worpro_name
              @is_main             = is_main
              @start_date          = start_date
              @tenki               = tenki
              @comment             = comment
              @master_shuushokugos = []
            end

            def to_s
              return @worpro_name if worpro?

              shoubyoumei_builder = ShoubyoumeiNameBuilder.new

              # @param shuushokugo [Master::Diagnosis::Shuushokugo]
              master_shuushokugos.each_with_object(shoubyoumei_builder) do | shuushokugo, builder |
                shuushokugo.prefix? ? builder.append_prefix(shuushokugo.name) : builder.append_suffix(shuushokugo.name)
              end

              shoubyoumei_builder.build_with(master_shoubyoumei.name)
            end

            # @param [Master::Diagnosis::Shuushokugo] shuushokugo
            # @return [void]
            def add_shuushokugo(shuushokugo)
              @master_shuushokugos << shuushokugo
            end

            # 主傷病か？
            def main?
              @is_main
            end

            def worpro?
              @master_shoubyoumei.code == WORPRO_SHOUBYOUMEI_CODE
            end

            # @!attribute [r] master_shoubyoumei
            #   @return [Master::Diagnosis::Shoubyoumei, DummyMasterShoubyoumei]
            attr_reader :master_shoubyoumei
            # @!attribute [r] master_shuushokugos
            #   @return [Array<Master::Diagnosis::Shuushokugo, DummyMasterShuushokugo>]
            attr_reader :master_shuushokugos
            attr_reader :start_date
            attr_reader :tenki
            attr_reader :comment

            class << self
              # @return [self]
              def dummy(code:, worpro_name:, is_main:, start_date:, tenki:, comment:)
                new(
                  master_shoubyoumei: DummyMasterShoubyoumei.new(code),
                  worpro_name:        worpro_name,
                  is_main:            is_main,
                  start_date:         start_date,
                  tenki:              tenki,
                  comment:            comment
                )
              end

              def dummy_master_shuushokugo(code:)
                DummyMasterShuushokugo.new(code)
              end
            end

            # マスタにレセ電コードが見つからなかった傷病名
            DummyMasterShoubyoumei = Struct.new(:code) do
              # @return [String]
              def name
                Formatter.to_zenkaku '【不明な傷病名：%s】' % code.value
              end
            end

            # マスタにレセ電コードが見つからなかった修飾語
            DummyMasterShuushokugo = Struct.new(:code) do
              # @return [String]
              def name
                Formatter.to_zenkaku '【不明な修飾語：%s】' % code.value
              end
            end

            def_delegators :master_shoubyoumei, :code

            # 転帰
            class Tenki
              def initialize(code:, name:)
                @code = code
                @name = name
              end

              # @!attribute [r] code
              #   @return [String]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name

              @types = {
                '1': new(code: 1, name: '継続'), # 治ゆ、死亡、中止以外
                '2': new(code: 2, name: '治癒'),
                '3': new(code: 3, name: '死亡'),
                '4': new(code: 4, name: '中止'),
              }
              @types.each(&:freeze).freeze

              class << self
                # @param code [String, Integer]
                # @return [self, nil]
                def find_by_code(code)
                  @types[code.to_s.intern]
                end
              end
            end

            class ShoubyoumeiNameBuilder
              def initialize
                @prefix = []
                @suffix = []
              end

              # @param text [String]
              # @return [void]
              def append_prefix(text)
                @prefix << text
              end

              # @param text [String]
              # @return [void]
              def append_suffix(text)
                @suffix << text
              end

              # @param shoubyoumei_name [String]
              # @return [String]
              def build_with(shoubyoumei_name)
                [@prefix, shoubyoumei_name, @suffix].flatten.join
              end
            end
          end
        end
      end
    end
  end
end
