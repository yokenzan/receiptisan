# frozen_string_literal: true

require 'month'
require 'forwardable'

require_relative 'receipt/tokki_jikou'
require_relative 'receipt/type'
require_relative 'receipt/shoubyoumei'
require_relative 'receipt/shoujou_shouki'
require_relative 'receipt/patient'
require_relative 'receipt/iryou_hoken'
require_relative 'receipt/kouhi_futan_iryou'
require_relative 'receipt/applied_hoken_list'
require_relative 'receipt/nissuu_kyuufu'
require_relative 'receipt/teishotoku_type'
require_relative 'receipt/shinryou_shikibetsu'
require_relative 'receipt/futan_kubun'
require_relative 'receipt/tekiyou'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        # 診療報酬請求明細書(レセプト)
        class Receipt
          extend Forwardable

          # @param id [Integer]
          # @param shinryou_ym [Month]
          # @param patient [Patient]
          # @param type [Type]
          # @param hospital [Hospital]
          def initialize(id:, shinryou_ym:, patient:, type:, nyuuin_date:)
            @id                 = id
            @shinryou_ym        = shinryou_ym
            @patient            = patient
            @type               = type
            @hospital           = nil
            @audit_payer        = nil
            @tokki_jikous       = {}
            @tekiyou            = Hash.new { | hash, key | hash[key] = [] }
            @hoken_list         = AppliedHokenList.new
            @shoubyoumeis       = []
            @shoujou_shoukis    = []
            @nyuuin_date        = nyuuin_date
            @byoushou_types     = []
          end

          # @param tokki_jikou [TokkiJikou]
          # @return [void]
          def add_tokki_jikou(tokki_jikou)
            @tokki_jikous[tokki_jikou.code] = tokki_jikou
          end

          # @param shoubyoumei [Shoubyoumei]
          # @return [void]
          def add_shoubyoumei(shoubyoumei)
            @shoubyoumeis << shoubyoumei
          end

          # @param ichiren_unit [Tekiyou::IchirenUnit]
          # @return [void]
          def add_ichiren_unit(ichiren_unit)
            @tekiyou[ichiren_unit.shinryou_shikibetsu.code] << ichiren_unit
          end

          # @param shoujou_shouki [ShoujouShouki]
          # @return [void]
          def add_shoujou_shouki(shoujou_shouki)
            @shoujou_shoukis << shoujou_shouki
          end

          # @param byoushou_type [ByoushouType]
          # @return [void]
          def add_byoushou_type(byoushou_type)
            @byoushou_types << byoushou_type
          end

          def nyuuin?
            @type.nyuuin?
          end

          def dates
            @tekiyou.map do | _, ichirens |
              ichirens.map do | ichiren |
                ichiren.map do | santei |
                  santei.each_date.map(&:date)
                end
              end
            end.flatten.uniq.sort
          end

          def each_date
            dates.each do | date |
              @tekiyou.each_value do | ichirens |
                ichirens = ichirens.select { | ichiren | ichiren.on_date(date) }.group_by(&:shinryou_shikibetsu)
                yield date, ichirens
              end
            end
          end

          # @return [void]
          def fix!
            @tekiyou = @tekiyou.sort_by { | shinryou_shikibetsu, _ | shinryou_shikibetsu.to_s.to_i }.to_h
          end

          # @!attribute [r] id
          #   @return [Integer]
          attr_reader :id
          # @!attribute [r] shinryou_ym
          #   @return [Month]
          attr_reader :shinryou_ym
          # @!attribute [r] patient
          #   @return [Patient]
          attr_reader :patient
          # @!attribute [r] type
          #   @return [Type]
          attr_reader :type
          # @!attribute [r] tokki_jikous
          #   @return [Hash<String, TokkiJikou]
          attr_reader :tokki_jikous
          # @!attribute [r] shoubyoumeis
          #   @return [Array<Shoubyoumei>]
          attr_reader :shoubyoumeis
          # @!attribute [r] nyuuin_date
          #   @return [Date, nil]
          attr_reader :nyuuin_date
          # @!attribute [r] byoushou_type
          #   @return [Array<ByoushouType>]
          attr_reader :byoushou_types
          # @!attribute [r] shoujou_shoukis
          #   @return [Array<ShoujouShouki>]
          attr_reader :shoujou_shoukis
          # @!attribute [rw] hospital
          #   @return [Hospital]
          attr_accessor :hospital
          # @!attribute [rw] hospital
          #   @return [AuditPayer]
          attr_accessor :audit_payer
          # @!attribute [rw] hoken_list
          #   @return [AppliedHokenList]
          attr_accessor :hoken_list

          def_delegators :@tekiyou, :each, :map, :[]
          # @!attribute [r] iryou_hoken
          #   @return [IryouHoken, nil]
          # @!attribute [r] kouhi_futan_iryous
          #   @return [Array<KouhiFutanIryou>, nil]
          def_delegators :@hoken_list, :iryou_hoken, :kouhi_futan_iryous
        end
      end
    end
  end
end
