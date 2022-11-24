# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          # 症状詳記
          class ShoujouShouki
            def initialize(category:, description:)
              @category    = category
              @description = description
            end

            # @!attribute [r] category
            #   @return [Category]
            # @!attribute [r] description
            #   @return [String]
            attr_reader :category, :description

            class Category
              def initialize(code, name)
                @code = code
                @name = name
              end

              # @!attribute [r] code
              #   @return [Symbol]
              # @!attribute [r] name
              #   @return [String]
              attr_reader :code, :name

              @list = {
                '01': new(:'01', '患者の主たる疾患（合併症を含む。）の診断根拠となった臨床症状'),
                '02': new(:'02', '患者の主たる疾患（合併症を含む。）の診断根拠となった臨床症状の診察・検査所見'),
                '03': new(:'03', '主な治療行為（手術、処置、薬物治療等）の必要性'),
                '04': new(:'04', '主な治療行為（手術、処置、薬物治療等）の経過'),
                '05': new(:'05', '診療報酬明細書の合計点数が１００万点以上の場合における薬剤に係る症状等'),
                '06': new(:'06', '診療報酬明細書の合計点数が１００万点以上の場合における処置に係る症状等'),
                '07': new(:'07', 'その他'),
                '50': new(:'50', '医薬品医療機器等法に規定する治験に係る治験概要'),
                '51': new(:'51', '疾患別リハビリテーション（心大血管疾患、脳血管疾患等、廃用症候群、運動器及び呼吸器）に係る治療継続の理由等の記載'),
                '52': new(:'52', '廃用症候群リハビリテーション料を算定する場合の、廃用をもたらすに至った要員等の記載'),
                '90': new(:'90', '上記以外の診療報酬明細書の場合'),
              }

              class << self
                # @param code [Integer, Symbol, String]
                # @return [Category, nil]
                def find_by_code(code)
                  @list[code.to_s.intern]
                end
              end
            end
          end
        end
      end
    end
  end
end
