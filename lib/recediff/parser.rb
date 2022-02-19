# frozen_string_literal: true
require 'csv'

module Recediff
  class Parser
    # @param [Master]           master
    # @param [DiseaseMaster]    disease_master
    # @param [ShushokugoMaster] shushokugo_master
    def initialize(master, disease_master, shushokugo_master, comment_master)
      @master            = master
      @disease_master    = disease_master
      @shushokugo_master = shushokugo_master
      @comment_master    = comment_master
    end

    # @param [String] uke_file_path
    # @return [Array<Receipt>]
    def parse(uke_file_path)
      buffer = Buffer.new

      CSV.foreach(uke_file_path, encoding: 'Windows-31J:UTF-8') { | row | parse_row(row, buffer) }

      buffer.close_current_receipt

      # buffer.receipts.each(&:sort!).sort_by(&:patient_id)
      buffer.receipts
    end

    def parse_area(text)
      buffer = Buffer.new

      buffer.new_empty_receipt unless is_receipt_row(text.split("\n").first)

      CSV.parse(text) { | row | parse_row(row, buffer) }

      buffer.close_current_receipt
      buffer.receipts
    end

    private

    def is_receipt_row(row)
      row =~ /\bRE\b/
    end

    def parse_row(row, buffer)
      case category = row.at(COST::CATEGORY)
      when /IR/
        buffer.hospital = Hospital.new(row)
      when /RE/
        buffer.new_receipt(
          Receipt.new(
            row.at(RE::RECEIPT_ID).to_i,
            row.at(RE::PATIENT_ID).to_i,
            row.at(RE::PATIENT_NAME),
            row.at(RE::TYPES),
            row.at(RE::TOKKI_JIKO),
            buffer.hospital
          )
        )
      when /HO/, /KO/
        buffer.receipt.add_hoken(row)
      when /SY/
        code = row.at(SYOBYO::CODE)
        disease = Syobyo::Disease.new(
          code,
          @disease_master.find_name_by_code(code) || row.at(SYOBYO::WORPRO_NAME)
        )
        syobyo = Syobyo.new(
          disease,
          row.at(SYOBYO::START_DATE),
          row.at(SYOBYO::TENKI),
          row.at(SYOBYO::IS_MAIN).to_i == 1
        )
        row.at(SYOBYO::SHUSHOKUGO)&.scan(/\d{4}/) do | code |
          syobyo.add_shushokugo(@shushokugo_master.find_by_code(code))
        end

        buffer.receipt.add_syobyo(syobyo)
      when /SJ/, /GO/, /IR/, /SN/
        ignore
      else
        add_cost(buffer, category, row)
      end
    end

    def add_cost(buffer, category, row)
      if shinku = row.at(COST::SHINKU)
        buffer.new_unit(CalcUnit.new(shinku.to_i))
      end

      unless comment?(category)
        cost = Cost.new(code = row.at(COST::CODE).to_i, @master.find_by_code(code), category, row)
        row[COST::COMMENT_CODE_1..COST::COMMENT_ADDITIONAL_TEXT_3].
          each_slice(2).
          reject { | code, additional_text | code.nil? }.
          each { | code, additional_text |
            cost.add_comment(
              Comment.new(
                CommentCore.new(
                  code.to_i,
                  @comment_master.find_by_code(code.to_i),
                  additional_text
                ),
                category,
                []
              )
            )
          }
        buffer.unit.add_cost(cost)
      else
        buffer.unit.add_cost(
          Comment.new(
            CommentCore.new(code = row.at(COST::CODE).to_i, @comment_master.find_by_code(code), row.at(4)),
            category,
            row
          )
        )
      end
    end

    def comment?(category)
      category =~ /CO/
    end

    def ignore; end

    class Buffer
      attr_reader :receipts, :unit, :receipt
      attr_accessor :hospital

      def initialize
        # @type [Array<Receipt>]
        @receipts = []
        @receipt  = nil
        @unit     = nil
        @hospital = nil
      end

      # @param [Receipt] receipt
      def new_receipt(receipt)
        close_current_receipt
        @receipt = receipt
      end

      def close_current_receipt
        close_current_unit

        if @receipt
          @receipt.remove_comment_only_units
          @receipt.reinitialize
          receipts << @receipt
        end

        @receipt = nil
      end


      def new_empty_receipt
        new_receipt(Receipt.new(
          'NOT FOUND',
          'NOT FOUND',
          'NOT FOUND',
          '',
          '',
          'NOT FOUND',
        ))
      end

      # @param [CalcUnit] unit
      def new_unit(unit)
        close_current_unit
        @unit = unit
      end

      private

      def close_current_unit
        @receipt.add_unit(unit) if unterminated_buffer?
        # receipt.add_unit(unit.sort!) if unterminated_buffer?
        @unit = nil
      end

      def unterminated_buffer?
        @receipt && unit && !unit.empty?
      end
    end
  end
end
