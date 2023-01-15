# frozen_string_literal: true

require_relative 'parser/master_handler'
require_relative 'parser/receipt_type_builder'
require_relative 'parser/comment_content_builder'
require_relative 'parser/hoken_order_provider'
require_relative 'parser/context'
require_relative 'parser/buffer'
require_relative 'parser/processor'

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser # rubocop:disable Metrics/ClassLength
          include Parser::Context::ErrorContextReportable
          using Receiptisan::Util::IOWithEncoding

          ReceiptType       = DigitalizedReceipt::Receipt::Type
          Comment           = Receipt::Tekiyou::Comment
          FILE_ENCODING     = 'Windows-31J'
          INTERNAL_ENCODING = 'UTF-8'

          # @param handler [MasterHandler]
          def initialize(handler, logger)
            @handler          = handler
            @logger           = logger
            @buffer           = Parser::Buffer.new
            @context          = Parser::Context.new
            processor_options = { context: context, logger: logger, handler: @handler }
            @processors       = {
              'IR' => Processor::IRProcessor.new,
              'RE' => Processor::REProcessor.new,
              'HO' => Processor::HOProcessor.new,
              'KO' => Processor::KOProcessor.new,
              'SY' => Processor::SYProcessor.new(**processor_options),
              'SJ' => Processor::SJProcessor.new,
              'SI' => Processor::SIProcessor.new(**processor_options),
              'IY' => Processor::IYProcessor.new(**processor_options),
              'TO' => Processor::TOProcessor.new(**processor_options),
            }
            @comment_content_builder = Parser::CommentContentBuilder.new(@handler, @processors['SY'])
          end

          # parse UKE contents
          #
          # @param io [IO]
          # @return [Array<DigitalizedReceipt>]
          def parse(io)
            context.prepare(io.inspect)
            buffer.prepare

            io.with_encoding(Parser::FILE_ENCODING, Parser::INTERNAL_ENCODING) do | encoded_io |
              encoded_io.each_line(chomp: true) do | line |
                context.update_current_line(line)
                parse_line(line2values(line))
              end
            end

            context.clear
            buffer.close
          end

          private

          # @param line [String]
          # @return [Array<String, nil>]
          def line2values(line)
            line.tr('"', '').split(',').map { | value | value.empty? ? nil : value }
          end

          # @param values [Array<String, nil>]
          # @return [void]
          # rubocop:disable Metrics/CyclomaticComplexity
          def parse_line(values)
            @current_processor = @processors[record_type = values.first]

            case record_type
            when 'IR' then process_ir(values)
            when 'RE'
              process_re(values)
              handler.prepare(buffer.current_shinryou_ym)
            when 'HO' then process_ho(values)
            when 'KO' then process_ko(values)
            when 'SN' then process_sn(values)
            when 'SY' then process_sy(values)
            when 'SJ' then process_sj(values)
            when 'SI' then process_si(values)
            when 'IY' then process_iy(values)
            when 'TO' then process_to(values)
            when 'CO' then process_co(values)
            else # when 'GO', 'JD', 'MF', nil
              ignore
            end
          rescue StandardError => e
            report_error(e)
          end
          # rubocop:enable Metrics/CyclomaticComplexity

          # @param values [Array<String, nil>]
          # @return [void]
          def process_ir(values)
            buffer.new_digitalized_receipt(current_processor.process(values))
          end

          # @param values [Array<String, nil>]
          # @return [void]
          def process_re(values)
            buffer.new_receipt(
              receipt = current_processor.process(values, buffer.current_audit_payer)
            )
            buffer.latest_kyuufu_wariai   = current_processor.kyuufu_wariai
            buffer.latest_teishotoku_type = current_processor.teishotoku_type

            context.current_receipt_id    = receipt.id
          end

          # @param values [Array<String, nil>]
          # @return [void]
          def process_ho(values)
            current_processor.process(
              values,
              buffer.latest_kyuufu_wariai,
              buffer.latest_teishotoku_type
            )&.then { | iryou_hoken | buffer.add_iryou_hoken(iryou_hoken) }
          end

          # @param values [Array<String, nil>]
          # @return [void]
          def process_ko(values)
            current_processor
              .process(buffer.nyuuin?, values)
              &.then { | kouhi_futan_iryou | buffer.add_kouhi_futan_iryou(kouhi_futan_iryou) }
          end

          # SN行を読込む
          #
          # 枝番を読込むだけ
          #
          # @param values [Array<String, nil>]
          # @return [void]
          def process_sn(values)
            buffer.current_iryou_hoken.update_edaban(values[Record::SN::C_枝番])
          end

          def process_sy(values)
            current_processor.process(values)&.then { | shoubyoumei | buffer.add_shoubyoumei(shoubyoumei) }
          end

          def process_si(values)
            current_processor.process(values)&.then { | resource | wrap_as_cost(resource, Record::SI, values) }
          end

          def process_iy(values)
            current_processor.process(values)&.then { | resource | wrap_as_cost(resource, Record::IY, values) }
          end

          def process_to(values)
            current_processor.process(values)&.then { | resource | wrap_as_cost(resource, Record::TO, values) }
          end

          def process_co(values)
            master_comment = handler.find_by_code(
              code = Master::Treatment::Comment::Code.of(values[Record::CO::C_レセ電コード])
            )
            shinryou_shikibetsu = Receipt::ShinryouShikibetsu.find_by_code(values[Record::CO::C_診療識別])
            futan_kubun = Receipt::FutanKubun.find_by_code(values[Record::CO::C_負担区分])

            comment = Comment.new(
              master_item:         master_comment,
              appended_content:    @comment_content_builder.build(master_comment.pattern, values[Record::CO::C_文字データ]),
              shinryou_shikibetsu: shinryou_shikibetsu,
              futan_kubun:         futan_kubun
            )

            buffer.add_tekiyou(comment)
          rescue Master::MasterItemNotFoundError => e
            report_error(e)

            comment = dummy_comment(
              code:                code,
              appended_value:      values[Record::CO::C_文字データ],
              shinryou_shikibetsu: shinryou_shikibetsu,
              futan_kubun:         futan_kubun
            )

            buffer.add_tekiyou(comment)
          end

          def process_sj(values)
            buffer.add_shoujou_shouki(current_processor.process(values))
          end

          def wrap_as_cost(resource, column_definition, values)
            cost = Receipt::Tekiyou::Cost.new(
              resource:            resource,
              shinryou_shikibetsu: Receipt::ShinryouShikibetsu.find_by_code(values[column_definition::C_診療識別]),
              futan_kubun:         Receipt::FutanKubun.find_by_code(values[column_definition::C_負担区分]),
              tensuu:              values[column_definition::C_点数]&.to_i,
              kaisuu:              values[column_definition::C_回数]&.to_i
            )

            comment_range = column_definition::C_コメント_1_コメントコード..column_definition::C_コメント_3_文字データ
            # @param code [String]
            # @param appended_value [String]
            values[comment_range].each_slice(2) do | code, appended_value |
              next if code.nil?

              begin
                master_comment = handler.find_by_code(Master::Treatment::Comment::Code.of(code))
                comment        = Comment.new(
                  master_item:         master_comment,
                  appended_content:    @comment_content_builder.build(master_comment.pattern, appended_value),
                  shinryou_shikibetsu: cost.shinryou_shikibetsu,
                  futan_kubun:         cost.futan_kubun
                )
              rescue Master::MasterItemNotFoundError => e
                report_error(e)

                comment = dummy_comment(
                  code:                code,
                  appended_value:      appended_value,
                  shinryou_shikibetsu: cost.shinryou_shikibetsu,
                  futan_kubun:         cost.futan_kubun
                )
              end

              cost.add_comment(comment)
            end

            buffer.add_tekiyou(cost)
          end

          def dummy_comment(code:, appended_value:, shinryou_shikibetsu:, futan_kubun:)
            Comment.dummy(
              code:                code,
              appended_content:    @comment_content_builder.build(_pattern = nil, appended_value),
              shinryou_shikibetsu: shinryou_shikibetsu,
              futan_kubun:         futan_kubun
            )
          end

          # @return [void]
          def ignore; end

          # @!attribute [r] buffer
          #   @return [Buffer]
          # @!attribute [r] handler
          #   @return [MasterHandler]
          attr_reader :buffer, :handler, :current_processor, :logger, :context
        end
      end
    end
  end
end
