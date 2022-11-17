# frozen_string_literal: true

require 'forwardable'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Receipt
          module Tekiyou
            # コメント
            class Comment
              extend Forwardable

              # @param item [Master::Treatment::Comment]
              # @param additional_comment [Additionalcomment, nil] コメント文
              # @param shinryou_shikibetsu [ShinryouShikibetsu, nil] 診療識別
              # @param futan_kubun [FutanKubun] 負担区分
              def initialize(
                master_item:,
                additional_comment:,
                shinryou_shikibetsu:,
                futan_kubun:
              )
                @master_item         = master_item
                @additional_comment  = additional_comment
                @shinryou_shikibetsu = shinryou_shikibetsu
                @futan_kubun         = futan_kubun
              end

              def tensuu?
                false
              end

              def kaisuu?
                false
              end

              def comment?
                true
              end

              # # 仮
              # def name
              #   to_s
              # end
              #
              # def to_s
              #   item.format_with(additional_comment)
              # end
              #
              # def tensuu
              #   nil
              # end
              #
              # def kaisuu
              #   nil
              # end
              #
              # def shiyouryou
              #   nil
              # end
              #
              # def unit
              #   nil
              # end
              #
              # def type
              #   :CO
              # end

              # @!attribute [r] item
              #   @return [Master::Treatment::Comment]
              # @!attribute [r] additional_comment
              #   @return [AdditionalComment, nil]
              # @!attribute [r] shinryou_shikibetsu
              #   @return [ShinryouShikibetsu, nil]
              # @!attribute [r] futan_kubun
              #   @return [FutanKubun]
              attr_reader :master_item, :additional_comment, :shinryou_shikibetsu, :futan_kubun

              # @!attribute [r] code
              #   @return [Master::Treatment::Comment::Code]
              # @!attribute [r] pattern
              #   @return [Master::Treatment::Comment::Pattern]
              def_delegators :master_item, :code
              # def_delegators :master_item, :code, :pattern

              class AdditionalComment
                @patterns = {
                  '10': proc {},
                  '20': proc {},
                  '30': proc {},
                  # @param text [String]
                  # @param handler [Parser::MasterHandler]
                  '31': lambda do | text, handler |
                    handler.find_by_code(Master::Treatment::ShinryouKoui::Code.of(text.tr('０-９', '0-9')))
                  end,
                  '40': proc { | text | text.gsub(/\A０+/, '　') },
                  '42': proc {},
                  '50': proc { | text | Recediff::Util::DateUtil.parse_date(text) },
                  '51': proc { | text | '%s時%s分' % [text[0, 2], text[2, 2]] },
                  '52': proc { | text | text.gsub(/\A０+/, '') + '分' },
                  '53': proc { | text | ('%s日%s時%s分' % text.scan(/\d\d/)).gsub(/\A０+/, '　') },
                  '80': proc do | text |
                    Struct.new(:date, :score) do
                      def name
                        '%s　検査値：%s' % [date, score]
                      end
                    end.new(
                      Recediff::Util::DateUtil.to_wareki(Recediff::Util::DateUtil.parse_date(text[0, 7])),
                      Time.new(date_text[0] + base_year, date_text[1], date_text[2]),
                      text[-8..].gsub(/\A０+/, '')
                    )
                  end,
                  # @param text [String]
                  # @param handler [Parser::MasterHandler]
                  '90': proc do | text, handler |
                    text
                      .tr('０-９', '0-9')
                      .scan(/\d{4}/)
                      .map { | code | handler.find_by_code(Master::Diagnose::Shuushokugo::Code.of(code)) }
                  end,
                }.freeze

                class << self
                  # @param master_comment [Master::Treatment::Comment]
                  # @param additional_text [String, nil]
                  # @param handler [Parser::MasterHandler, Master]
                  # @return [self, nil]
                  def build(master_comment, additional_text, handler)
                    return unless additional_text

                    new(
                      value: additional_text,
                      item:  @patterns[master_comment.pattern.code].call(additional_text, handler)
                    )
                  end
                end

                # @param value [String]
                # @param item [Master::Treatment::ShinryouKoui, Master::Diagnose::Shoubyoumei, nil]
                def initialize(value:, item:)
                  @value = value
                  @item  = item
                end

                attr_reader :value, :item
              end
            end
          end
        end
      end
    end
  end
end
