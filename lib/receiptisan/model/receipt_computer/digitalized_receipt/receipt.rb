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
          def initialize(id:, shinryou_ym:, patient:, type:)
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

          def nyuuin?
            @type.nyuuin?
          end

          def to_s
            @tekiyou.values.flatten.map(&:to_s).join("\n")
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
          #   @return [Hash<TokkiJikou]
          attr_reader :tokki_jikous
          # @!attribute [r] hoken_list
          #   @return [AppliedHokenList]
          attr_reader :hoken_list
          # @!attribute [r] shoubyoumeis
          #   @return [Array<Shoubyoumei>]
          attr_reader :shoubyoumeis
          # @!attribute [r] shoujou_shoukis
          #   @return [Array<ShoujouShouki>]
          attr_reader :shoujou_shoukis
          # @!attribute [rw] hospital
          #   @return [Hospital]
          attr_accessor :hospital
          # @!attribute [rw] hospital
          #   @return [AuditPayer]
          attr_accessor :audit_payer

          def_delegators :@tekiyou, :each, :map, :[]
          # @!attribute [r] iryou_hoken
          #   @return [IryouHoken, nil]
          # @!attribute [r] kouhi_futan_iryous
          #   @return [Array<KouhiFutanIryou>, nil]
          def_delegators :@hoken_list,
            :iryou_hoken,
            :kouhi_futan_iryous,
            :add_iryou_hoken,
            :add_kouhi_futan_iryou
        end
      end
    end
  end
end
