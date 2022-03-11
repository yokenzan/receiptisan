# frozen_string_literal: true

require 'csv'

module Recediff
  class Parser
    class << self
      def create
        new(
          Recediff::Master.load('./csv'),
          Recediff::DiseaseMaster.load('./csv'),
          Recediff::ShushokugoMaster.load('./csv'),
          Recediff::CommentMaster.load('./csv')
        )
      end
    end
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
    # @param [Array<Integer>] seqs
    # @return [Array<Receipt>]
    def parse(uke_file_path, seqs = [])
      buffer = Buffer.new(seqs, seqs.empty?)

      CSV.foreach(uke_file_path, encoding: 'Windows-31J:UTF-8') { | row | parse_row(row, buffer) }

      buffer.close_current_receipt

      buffer.receipts
    end

    # @param [String] text
    def parse_area(text)
      text.encode!(Encoding::UTF_8) unless text.encoding == Encoding::UTF_8

      buffer = Buffer.new
      first_row = text.split("\n").first

      buffer.new_empty_receipt if !receipt_row?(first_row) && !hospital_row?(first_row)

      CSV.parse(text) { | row | parse_row(row, buffer) }

      buffer.close_current_receipt
      buffer.receipts
    rescue ArgumentError => e
      raise e unless e.message.include?('invalid byte sequence in UTF-8')

      text.force_encoding(Encoding::Shift_JIS).encode!(Encoding::UTF_8, Encoding::Shift_JIS)
      retry
    end

    private

    def hospital_row?(row)
      row =~ /\bIR\b/
    end

    def receipt_row?(row)
      row =~ /\bRE\b/
    end

    def parse_row(row, buffer)
      case category = row.at(COST::CATEGORY)
      when /IR/
        buffer.hospital = Hospital.new(row)
      when /RE/
        update_seq_condition(row, buffer)
        new_receipt(row, buffer)
      when /HO/, /KO/
        buffer.in_seq? && buffer.receipt.add_hoken(row)
      when /SY/
        add_syobyo(row, buffer)
      when /SJ/, /GO/, /SN/
        ignore
      else
        add_cost(buffer, category, row)
      end
    end

    def update_seq_condition(row, buffer)
      buffer.update_seq_condition(row.at(RE::RECEIPT_ID).to_i)
    end

    def new_receipt(row, buffer)
      return unless buffer.in_seq?

      receipt = Receipt.new(
        row.at(RE::RECEIPT_ID).to_i,
        row.at(RE::PATIENT_ID).to_i,
        row.at(RE::PATIENT_NAME),
        row.at(RE::TYPES),
        row.at(RE::TOKKI_JIKO),
        buffer.hospital
      )
      buffer.new_receipt(receipt)
    end

    def add_syobyo(row, buffer)
      return unless buffer.in_seq?

      code    = row.at(SYOBYO::CODE)
      name    = @disease_master.find_name_by_code(code) || row.at(SYOBYO::WORPRO_NAME)
      disease = Syobyo::Disease.new(code, name)
      syobyo  = Syobyo.new(
        disease,
        row.at(SYOBYO::START_DATE),
        row.at(SYOBYO::TENKI),
        row.at(SYOBYO::IS_MAIN).to_i == 1
      )
      row.at(SYOBYO::SHUSHOKUGO)&.scan(/\d{4}/) do | c |
        syobyo.add_shushokugo(@shushokugo_master.find_by_code(c))
      end

      buffer.receipt.add_syobyo(syobyo)
    end

    def add_cost(buffer, category, row)
      return unless buffer.in_seq?

      if (shinku = row.at(COST::SHINKU))
        buffer.new_unit(CalcUnit.new(shinku.to_i))
      end

      unless comment?(category)
        cost = Cost.new(code = row.at(COST::CODE).to_i, @master.find_by_code(code), category, row)
        row[COST::COMMENT_CODE_1..COST::COMMENT_ADDITIONAL_TEXT_3]
          .each_slice(2)
          .reject { | c, _ | c.nil? }
          .each do | c, additional_text |
            comment_text = @comment_master.find_by_code(c.to_i)
            comment_core = CommentCore.new(c.to_i, comment_text, additional_text)
            cost.add_comment(Comment.new(comment_core, category, []))
          end
        buffer.unit.add_cost(cost)
      else
        code         = row.at(COST::CODE).to_i
        comment_text = @comment_master.find_by_code(code.to_i)
        comment_core = CommentCore.new(code.to_i, comment_text, row.at(4))
        buffer.unit.add_cost(Comment.new(comment_core, category, row))
      end
    end

    def comment?(category)
      category =~ /CO/
    end

    def ignore; end

    class Buffer
      attr_reader :receipts, :unit, :receipt, :seqs
      attr_accessor :hospital

      def initialize(seqs = [], in_seq = nil)
        # @type [Array<Receipt>]
        @seqs          = seqs
        @seq_condition = in_seq || seqs.empty?
        @seq_condition = !!@seq_condition
        @receipts      = []
        @receipt       = nil
        @unit          = nil
        @hospital      = nil
      end

      def in_seq?
        !!@seq_condition
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
          @hospital || 'NOT FOUND'
        ))
      end

      # @param [CalcUnit] unit
      def new_unit(unit)
        close_current_unit
        @unit = unit
      end

      # @param [Integer] receipt_seq
      def update_seq_condition(receipt_seq)
        @seq_condition = @seqs.empty? || @seqs.bsearch { | s | s == receipt_seq }
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
