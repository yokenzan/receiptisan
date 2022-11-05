# frozen_string_literal: true

require 'forwardable'
require_relative 'digitalized_receipt/hospital'
require_relative 'digitalized_receipt/patient'
require_relative 'digitalized_receipt/receipt'
require_relative 'digitalized_receipt/iryou_hoken'
require_relative 'digitalized_receipt/kouhi_futan_iryou'
require_relative 'digitalized_receipt/shoubyoumei'
require_relative 'digitalized_receipt/nissuu_kyuufu'
require_relative 'digitalized_receipt/record'
require_relative 'digitalized_receipt/parser'

module Recediff
  module Model
    module ReceiptComputer
      # 電子レセプト(RECEIPTC.UKE)
      # 診療報酬請求書
      class DigitalizedReceipt
        extend Forwardable

        # @param seikyuu_ym [Month]
        # @param audit_payer [AuditPayer]
        # @param hospital [Hospital]
        def initialize(seikyuu_ym:, audit_payer:, hospital:)
          @seikyuu_ym  = seikyuu_ym
          @audit_payer = audit_payer
          @hospital    = hospital
          @receipts    = []
        end

        # @param receipt [Receipt]
        # @return nil
        def add_receipt(receipt)
          @receipts << receipt
          # @receipts[receipt.id] = receipt
        end

        # @!attribute [r] seikyuu_ym
        #   @return [Month]
        # @!attribute [r] audit_payer
        #   @return [AuditPayer]
        # @!attribute [r] hospital
        #   @return [Hospital]
        attr_reader :seikyuu_ym, :audit_payer, :hospital

        def_delegators :@receipts, :each, :each_with_index, :map, :to_a, :[]

        # 性別(男女区分)
        class Sex
          def initialize(code:, name:)
            @code = code
            @name = name
          end

          # @!attribute [r] code
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          attr_reader :code, :name

          @sexes = {
            '1': new(code: 1, name: '男性'),
            '2': new(code: 2, name: '女性'),
          }

          class << self
            # @param code [String, Integer]
            # @return [self, nil]
            def find_by_code(code)
              @sexes[code.to_s.intern]
            end
          end
        end

        # 審査支払機関
        class AuditPayer
          def initialize(code:, name:, short_name:)
            @code       = code
            @name       = name
            @short_name = short_name
          end

          # @!attribute [r] code
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          # @!attribute [r] short_name
          #   @return [String]
          attr_reader :code, :name, :short_name

          @payers = {
            '1': new(code: 1, name: '社会保険診療報酬支払基金', short_name: '社'),
            '2': new(code: 2, name: '国民健康保険団体連合会',   short_name: '国'),
          }

          class << self
            # @param code [String, Integer]
            # @return [self, nil]
            def find_by_code(code)
              @payers[code.to_s.intern]
            end
          end
        end

        # 都道府県
        class Prefecture
          def initialize(code:, name:)
            @code = code
            @name = name
          end

          def name_without_suffix
            name.sub(/[都府県]$/, '')
          end

          # @!attribute [r] code
          #   @return [String]
          # @!attribute [r] name
          #   @return [String]
          attr_reader :code, :name

          @prefectures = {
            '1':  Prefecture.new(code: 1,  name: '北海道'),
            '2':  Prefecture.new(code: 2,  name: '青森県'),
            '3':  Prefecture.new(code: 3,  name: '岩手県'),
            '4':  Prefecture.new(code: 4,  name: '宮城県'),
            '5':  Prefecture.new(code: 5,  name: '秋田県'),
            '6':  Prefecture.new(code: 6,  name: '山形県'),
            '7':  Prefecture.new(code: 7,  name: '福島県'),
            '8':  Prefecture.new(code: 8,  name: '茨城県'),
            '9':  Prefecture.new(code: 9,  name: '栃木県'),
            '10': Prefecture.new(code: 10, name: '群馬県'),
            '11': Prefecture.new(code: 11, name: '埼玉県'),
            '12': Prefecture.new(code: 12, name: '千葉県'),
            '13': Prefecture.new(code: 13, name: '東京都'),
            '14': Prefecture.new(code: 14, name: '神奈川県'),
            '15': Prefecture.new(code: 15, name: '新潟県'),
            '16': Prefecture.new(code: 16, name: '富山県'),
            '17': Prefecture.new(code: 17, name: '石川県'),
            '18': Prefecture.new(code: 18, name: '福井県'),
            '19': Prefecture.new(code: 19, name: '山梨県'),
            '20': Prefecture.new(code: 20, name: '長野県'),
            '21': Prefecture.new(code: 21, name: '岐阜県'),
            '22': Prefecture.new(code: 22, name: '静岡県'),
            '23': Prefecture.new(code: 23, name: '愛知県'),
            '24': Prefecture.new(code: 24, name: '三重県'),
            '25': Prefecture.new(code: 25, name: '滋賀県'),
            '26': Prefecture.new(code: 26, name: '京都府'),
            '27': Prefecture.new(code: 27, name: '大阪府'),
            '28': Prefecture.new(code: 28, name: '兵庫県'),
            '29': Prefecture.new(code: 29, name: '奈良県'),
            '30': Prefecture.new(code: 30, name: '和歌山県'),
            '31': Prefecture.new(code: 31, name: '鳥取県'),
            '32': Prefecture.new(code: 32, name: '島根県'),
            '33': Prefecture.new(code: 33, name: '岡山県'),
            '34': Prefecture.new(code: 34, name: '広島県'),
            '35': Prefecture.new(code: 35, name: '山口県'),
            '36': Prefecture.new(code: 36, name: '徳島県'),
            '37': Prefecture.new(code: 37, name: '香川県'),
            '38': Prefecture.new(code: 38, name: '愛媛県'),
            '39': Prefecture.new(code: 39, name: '高知県'),
            '40': Prefecture.new(code: 40, name: '福岡県'),
            '41': Prefecture.new(code: 41, name: '佐賀県'),
            '42': Prefecture.new(code: 42, name: '長崎県'),
            '43': Prefecture.new(code: 43, name: '熊本県'),
            '44': Prefecture.new(code: 44, name: '大分県'),
            '45': Prefecture.new(code: 45, name: '宮崎県'),
            '46': Prefecture.new(code: 46, name: '鹿児島県'),
            '47': Prefecture.new(code: 47, name: '沖縄県'),
          }
          @prefectures.each(&:freeze).freeze

          class << self
            # @param code [String, Integer]
            def find_by_code(code)
              @prefectures[code.to_s.intern]
            end
          end
        end
      end
    end
  end
end
