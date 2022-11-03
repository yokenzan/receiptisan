# frozen_string_literal: true

require 'month'
require 'forwardable'

require_relative 'receipt/tokki_jikou'
require_relative 'receipt/type'
require_relative 'receipt/shinryou_koui'
require_relative 'receipt/iyakuhin'
require_relative 'receipt/tokutei_kizai'
require_relative 'receipt/comment'
require_relative 'receipt/shinryou_shikibetsu'
require_relative 'receipt/futan_kubun'
require_relative 'receipt/cost'
require_relative 'receipt/ichiren_unit'
require_relative 'receipt/santei_unit'
require_relative 'receipt/shoujou_shouki'

module Recediff
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
            @tokki_jikous       = {}
            @tekiyou            = Hash.new { | hash, key | hash[key] = [] }
            @iryou_hoken        = nil
            @kouhi_futan_iryous = []
            @shoubyoumeis       = []
            @shoujou_shoukis    = []
          end

          # @param tokki_jikou [TokkiJikou]
          # @return [void]
          def add_tokki_jikou(tokki_jikou)
            @tokki_jikous[tokki_jikou.code] = tokki_jikou
          end

          # @param iryou_hoken [IryouHoken]
          # @return [void]
          def add_iryou_hoken(iryou_hoken)
            @iryou_hoken = iryou_hoken
          end

          # @param kouhi_futan_iryou [KouhiFutanIryou]
          # @return [void]
          def add_kouhi_futan_iryou(kouhi_futan_iryou)
            @kouhi_futan_iryous << kouhi_futan_iryou
          end

          # @param shoubyoumei [Shoubyoumei]
          # @return [void]
          def add_shoubyoumei(shoubyoumei)
            @shoubyoumeis << shoubyoumei
          end

          # @param ichiren_unit [IchirenUnit]
          # @return [void]
          def add_ichiren_unit(ichiren_unit)
            @tekiyou[ichiren_unit.shinryou_shikibetsu] << ichiren_unit
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
          # @!attribute [r] iryou_hoken
          #   @return [IryouHoken, nil]
          attr_reader :iryou_hoken
          # @!attribute [r] kouhi_futan_iryous
          #   @return [Array<KouhiFutanIryou>, nil]
          attr_reader :kouhi_futan_iryous
          # @!attribute [r] shoubyoumeis
          #   @return [Array<Shoubyoumei>]
          attr_reader :shoubyoumeis
          # @!attribute [r] shoujou_shoukis
          #   @return [Array<ShoujouShouki>]
          attr_reader :shoujou_shoukis
          # @!attribute [rw] hospital
          #   @return [Hospital]
          attr_accessor :hospital

          def_delegators :@tekiyou, :each, :map
        end
      end
    end
  end
end
