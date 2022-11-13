# frozen_string_literal: true

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # 診療識別
          class ShinryouShikibetsu
            def initialize(code:, name:)
              @code = code
              @name = name
            end

            # @!attribute [r] code
            #   @return [String]
            # @!attribute [r] name
            #   @return [String]
            attr_reader :code, :name

            @list = {
              '01': new(code: '01', name: '全体に係る識別コード'),
              '11': new(code: '11', name: '初診'),
              '12': new(code: '12', name: '再診'),
              '13': new(code: '13', name: '医学管理'),
              '14': new(code: '14', name: '在宅'),
              '21': new(code: '21', name: '投薬・内服'),
              '22': new(code: '22', name: '投薬・屯服'),
              '23': new(code: '23', name: '投薬・外用'),
              '24': new(code: '24', name: '投薬・調剤'),
              '25': new(code: '25', name: '投薬・調剤'),
              '26': new(code: '26', name: '投薬・麻毒'),
              '27': new(code: '27', name: '投薬・調基'),
              '28': new(code: '28', name: '投薬・その他'),
              '31': new(code: '31', name: '注射・皮下筋肉内'),
              '32': new(code: '32', name: '注射・静脈内'),
              '33': new(code: '33', name: '注射・その他'),
              '39': new(code: '39', name: '薬剤料減点'),
              '40': new(code: '40', name: '処置'),
              '50': new(code: '50', name: '手術'),
              '54': new(code: '54', name: '麻酔'),
              '60': new(code: '60', name: '検査・病理'),
              '70': new(code: '70', name: '画像診断'),
              '80': new(code: '80', name: 'その他'),
              '90': new(code: '90', name: '入院・入院基本料'),
              '92': new(code: '92', name: '入院・特定入院料・その他'),
              '97': new(code: '97', name: '食事療養・生活療養・標準負担額'),
              '99': new(code: '99', name: '全体に係る識別コード'),
            }
            @list.each(&:freeze).freeze

            class << self
              # @param code [String, Integer]
              # @return [self, nil]
              def find_by_code(code)
                @list[('%02d' % code.to_i).intern]
              end
            end
          end
        end
      end
    end
  end
end
