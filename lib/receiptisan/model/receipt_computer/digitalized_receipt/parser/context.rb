# frozen_string_literal: true

module Receiptisan
  module Model
    module ReceiptComputer
      class DigitalizedReceipt
        class Parser
          class Context
            def initialize
              clear
            end

            # @return [void]
            def prepare(uke_file_path)
              @uke_file_path       = uke_file_path
              @current_line        = nil
              @current_line_number = 0
              @current_receipt_id  = nil
            end

            # @param line [String]
            # @return [void]
            def update_current_line(line)
              @current_line         = line
              @current_line_number += 1
            end

            # @return [void]
            def clear
              prepare(_uke_file_path = nil)
            end

            # @!attribute [r] current_line
            #   @return [String, nil]
            # @!attribute [r] current_line_number
            #   @return [Integer]
            # @!attribute [r] uke_file_path
            #   @return [String, nil]
            attr_reader :current_line, :current_line_number, :uke_file_path
            # @!attribute [rw] current_receipt_id
            #   @return [Integer, nil]
            attr_accessor :current_receipt_id

            module ErrorContextReportable
              # @param e [Exception]
              # @return [void]
              def report_error(e, severity = Logger::WARN)
                # ブロックをつかっていないのはスタックトレースも表示するため
                message = 'Exception occurred while parsing %s:%d:%s' % [
                  context.uke_file_path,
                  context.current_line_number,
                  context.current_line,
                ]
                logger.add(severity, message)
                # レセプト内にいるとき(IR行や最初のRE行の読込時以外)はレセプト番号も出力する
                logger.add(severity, 'RECEIPT ID:%d' % context.current_receipt_id) if context.current_receipt_id
                logger.add(severity, e)
              end

              def logger
                raise NotImplementedError, 'should override #logger'
              end

              def context
                raise NotImplementedError, 'should override #context'
              end
            end
          end
        end
      end
    end
  end
end
