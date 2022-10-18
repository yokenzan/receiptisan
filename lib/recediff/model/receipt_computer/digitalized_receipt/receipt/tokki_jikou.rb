# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          class TokkiJikou
            def initialize(code:, name:)
              @code = code
              @name = name
            end

            # @!attribute [r] code
            #   @return [String]
            # @!attribute [r] name
            #   @return [String]
            attr_reader :code, :name

            @tokki_jikous = {
              '01': TokkiJikou.new(code: '01', name: '公'),
              '02': TokkiJikou.new(code: '02', name: '長'),
              '03': TokkiJikou.new(code: '03', name: '長処'),
              '04': TokkiJikou.new(code: '04', name: '後保'),
              '07': TokkiJikou.new(code: '07', name: '老併'),
              '08': TokkiJikou.new(code: '08', name: '老健'),
              '09': TokkiJikou.new(code: '09', name: '施'),
              '10': TokkiJikou.new(code: '10', name: '第三'),
              '11': TokkiJikou.new(code: '11', name: '薬治'),
              '12': TokkiJikou.new(code: '12', name: '器治'),
              '13': TokkiJikou.new(code: '13', name: '先進'),
              '14': TokkiJikou.new(code: '14', name: '制超'),
              '16': TokkiJikou.new(code: '16', name: '長２'),
              '20': TokkiJikou.new(code: '20', name: '二割'),
              '21': TokkiJikou.new(code: '21', name: '高半'),
              '25': TokkiJikou.new(code: '25', name: '出産'),
              '26': TokkiJikou.new(code: '26', name: '区ア'),
              '27': TokkiJikou.new(code: '27', name: '区イ'),
              '28': TokkiJikou.new(code: '28', name: '区ウ'),
              '29': TokkiJikou.new(code: '29', name: '区エ'),
              '30': TokkiJikou.new(code: '30', name: '区オ'),
              '31': TokkiJikou.new(code: '31', name: '多ア'),
              '32': TokkiJikou.new(code: '32', name: '多イ'),
              '33': TokkiJikou.new(code: '33', name: '多ウ'),
              '34': TokkiJikou.new(code: '34', name: '多エ'),
              '35': TokkiJikou.new(code: '35', name: '多オ'),
              '36': TokkiJikou.new(code: '36', name: '加治'),
              '37': TokkiJikou.new(code: '37', name: '申出'),
              '38': TokkiJikou.new(code: '38', name: '医併'),
              '39': TokkiJikou.new(code: '39', name: '医療'),
              '96': TokkiJikou.new(code: '96', name: '災１'),
              '97': TokkiJikou.new(code: '97', name: '災２'),
            }
            class << self
              # @param code [String, Integer]
              # @return [self, nil]
              def find_by_code(code)
                @tokki_jikous[('%02d' % code.to_i).intern]
              end
            end
          end
        end
      end
    end
  end
end
