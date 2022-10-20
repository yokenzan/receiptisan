# frozen_string_literal: true

require 'date'
require 'month'
require_relative 'parser/buffer'

module Recediff
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser # rubocop:disable Metrics/ClassLength
          ReceiptType   = DigitalizedReceipt::Receipt::Type
          FILE_ENCODING = 'Shift_JIS'

          # @param master_loader [Master::Loader]
          def initialize(master_loader)
            @master_loader  = master_loader
            # @type [Hash<Master::Version, Master>]
            @loaded_masters = {}
            # @type [Master, nil]
            @current_master = nil
            @buffer         = Parser::Buffer.new
          end

          # @param path [String]
          # @return [DigitalizedReceipt]
          def parse(path)
            buffer.clear

            File.open(path, "r:#{FILE_ENCODING}:UTF-8") do | f |
              # @param line [String]
              f.each_line(chomp: true) do | line |
                parse_line(line.tr('"', '').split(','))
              end
            end

            buffer.close
          end

          private

          # @param values [Array<String, nil>]
          # @return [void]
          def parse_line(values)
            case record_type = values.first
            when 'IR' then process_ir(values)
            when 'RE'
              process_re(values)
              @current_master = prepare_master(buffer.current_receipt.shinryou_ym)
            when 'HO' then process_ho(values)
            when 'KO' then process_ko(values)
            when 'SN' then process_sn(values)
            when 'SY' then process_sy(values)
            when 'SJ' then process_sj(values)
            when 'SI' then process_si(values)
            when 'IY' then process_iy(values)
            when 'TO' then process_to(values)
            when 'CO' then process_co(values)
            when 'GO', 'JD', 'MF', nil
              ignore
            else
              record_type
            end
          end

          # @param values [Array<String, nil>]
          # @return [void]
          def process_ir(values)
            buffer.new_digitalized_receipt(DigitalizedReceipt.new(
              seikyuu_ym:  values[Record::IR::C_請求年月],
              audit_payer: AuditPayer.find_by_code(
                values[Record::IR::C_審査支払機関].to_i
              ),
              hospital:    Hospital.new(
                code:       values[Record::IR::C_医療機関コード],
                name:       values[Record::IR::C_医療機関名称],
                tel:        values[Record::IR::C_電話番号],
                prefecture: Prefecture.find_by_code(
                  values[Record::IR::C_都道府県].to_i
                )
              )
            ))
          end

          # @param values [Array<String, nil>]
          # @return [void]
          def process_re(values)
            buffer.new_receipt(Receipt.new(
              id:          values[Record::RE::C_レセプト番号].to_i,
              shinryou_ym: Month.new(
                values[Record::RE::C_診療年月][0,  4].to_i,
                values[Record::RE::C_診療年月][-1, 2].to_i
              ),
              type:        ReceiptType.of(values[Record::RE::C_レセプト種別]),
              patient:     Patient.new(
                id:         values[Record::RE::C_カルテ番号等],
                name:       values[Record::RE::C_氏名],
                name_kana:  values[Record::RE::C_カタカナ氏名],
                sex:        Sex.find_by_code(values[Record::RE::C_男女区分]),
                birth_date: Date.parse(values[Record::RE::C_生年月日])
              )
            ))

            values[Record::RE::C_レセプト特記事項].scan(/\d\d/) do | code |
              buffer.current_receipt.add_tokki_jikou(Receipt::TokkiJikou.find_by_code(code))
            end
          end

          # @param values [Array<String, nil>]
          # @return [void]
          def process_ho(values)
            buffer.current_receipt.add_iryou_hoken(IryouHoken.new(
              hokenja_bangou: values[Record::HO::C_保険者番号],
              kigou:          values[Record::HO::C_被保険者証等の記号],
              bangou:         values[Record::HO::C_被保険者証等の番号],
              gemmen_kubun:   values[Record::HO::C_負担金額_減免区分],
              nissuu_kyuufu:  NissuuKyuufu.new(
                goukei_tensuu:                           values[Record::HO::C_合計点数]&.to_i,
                shinryou_jitsunissuu:                    values[Record::HO::C_診療実日数]&.to_i,
                ichibu_futankin:                         values[Record::HO::C_負担金額_医療保険]&.to_i,
                kyuufu_taishou_ichibu_futankin:          nil,
                shokuji_seikatsu_ryouyou_kaisuu:         values[Record::HO::C_食事療養・生活療養_回数]&.to_i,
                shokuji_seikatsu_ryouyou_goukei_kingaku: values[Record::HO::C_食事療養・生活療養_合計金額]&.to_i
              )
            ))
          end

          # @param values [Array<String, nil>]
          # @return [void]
          def process_ko(values)
            buffer.current_receipt.add_kouhi_hutan_iryou(KouhiFutanIryou.new(
              futansha_bangou:  values[Record::KO::C_公費負担者番号],
              jukyuusha_bangou: values[Record::KO::C_公費受給者番号],
              nissuu_kyuufu:    NissuuKyuufu.new(
                goukei_tensuu:                           values[Record::KO::C_合計点数].to_i,
                shinryou_jitsunissuu:                    values[Record::KO::C_診療実日数].to_i,
                ichibu_futankin:                         values[Record::KO::C_負担金額_公費]&.to_i,
                kyuufu_taishou_ichibu_futankin:
                  (values[Record::KO::C_公費給付対象外来一部負担金] || values[Record::KO::C_公費給付対象入院一部負担金])&.to_i,
                shokuji_seikatsu_ryouyou_kaisuu:         values[Record::KO::C_食事療養・生活療養_回数]&.to_i,
                shokuji_seikatsu_ryouyou_goukei_kingaku: values[Record::KO::C_食事療養・生活療養_合計金額]&.to_i
              )
            ))
          end

          # SN行を読込む
          #
          # 枝番を読込むだけ
          #
          # @param values [Array<String, nil>]
          # @return [void]
          def process_sn(values)
            buffer.current_receipt.iryou_hoken.update_edaban(values[Record::SN::C_枝番])
          end

          def process_sy(values)
            shoubyoumei = Shoubyoumei.new(
              master_shoubyoumei: @current_master.find_by_code(
                Master::ShoubyoumeiCode.of(values[Record::SY::C_傷病名コード])
              ),
              name:               values[Record::SY::C_傷病名称],
              is_main:            values[Record::SY::C_主傷病],
              start_date:         values[Record::SY::C_診療開始日],
              tenki:              Shoubyoumei::Tenki.find_by_code(values[Record::SY::C_転帰区分]),
              additional_comment: values[Record::SY::C_補足コメント]
            )

            values[Record::SY::C_修飾語コード]&.scan(/\d{4}/) do | c |
              shoubyoumei.add_shuushokugo(@current_master.find_by_code(Master::ShuushokugoCode.of(c)))
            end

            buffer.current_receipt.add_shoubyoumei(shoubyoumei)
          end

          def process_si(values)
            shinryou_koui = Receipt::ShinryouKoui.new(
              shiyouryou:           values[Record::SI::C_数量データ].to_i,
              master_shinryou_koui: @current_master.find_by_code(
                Master::ShinryouKouiCode.of(values[Record::SI::C_レセ電コード])
              )
            )

            add_as_cost(shinryou_koui, Record::SI, values)
          end

          def process_iy(values)
            iyakuhin = Receipt::Iyakuhin.new(
              master_iyakuhin: @current_master.find_by_code(Master::IyakuhinCode.of(values[Record::IY::C_レセ電コード])),
              shiyouryou:      values[Record::IY::C_使用量].to_i
            )

            add_as_cost(iyakuhin, Record::IY, values)
          end

          def process_to(values); end

          def process_co(values)
            master_comment = @current_master.find_by_code(Master::CommentCode.of(values[Record::CO::C_レセ電コード]))
            comment        = DigitalizedReceipt::Receipt::Comment.new(
              master_comment:      master_comment,
              additional_text:     values[Record::CO::C_文字データ],
              shinryou_shikibetsu: Receipt::ShinryouShikibetsu.find_by_code(values[Record::CO::C_診療識別]),
              futan_kubun:         values[Record::CO::C_負担区分]
            )

            buffer.add_tekiyou(comment)
          end

          def process_sj(values); end

          def add_as_cost(item, column_definition, values)
            cost = Cost.new(
              item:                item,
              shinryou_shikibetsu: Receipt::ShinryouShikibetsu.find_by_code(values[column_definition::C_診療識別]),
              futan_kubun:         values[column_definition::C_負担区分],
              tensuu:              values[column_definition::C_点数],
              kaisuu:              values[column_definition::C_回数]
            )

            comment_range = column_definition::C_コメント_1_コメントコード..column_definition::C_コメント_3_文字データ
            # @param code [String]
            # @param additional_text [String]
            values[comment_range].each_slice(2) do | code, additional_text |
              next if code.empty?

              comment = Receipt::Comment.new(
                master_comment:      @current_master.find_by_code(Master::CommentCode.of(comment)),
                additional_text:     additional_text,
                futan_kubun:         cost.futan_kubun,
                shinryou_shikibetsu: cost.shinryou_shikibetsu
              )
              cost.add_comment(comment)
            end

            buffer.add_tekiyou(cost)
          end

          # 新しいレセプトを読込む都度、レセプトの診療年月にあわせた版のマスタを用意する
          #
          # @param shinryou_ym [Month]
          # @return [Master]
          def prepare_master(shinryou_ym)
            version = Master::Version.resolve_by_ym(shinryou_ym)
            @loaded_masters[version] ||= @master_loader.load(version)
          end

          # @return [void]
          def ignore; end

          attr_reader :buffer
        end
      end
    end
  end
end
