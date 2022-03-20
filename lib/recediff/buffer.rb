# frozen_string_literal: true

module Recediff
  class Buffer
    attr_reader :receipts, :unit, :receipt, :seqs
    attr_accessor :hospital

    def initialize(seqs = [], in_seq = nil)
      @seqs          = seqs
      @seq_condition = !!(in_seq || seqs.empty?)
      @walked_seqs   = []
      # @type [Array<Receipt>]
      @receipts      = []
      # @type [Receipt?]
      @receipt       = nil
      # @type [CalcUnit?]
      @unit          = nil
      # @type [Hospital?]
      @hospital      = nil
      @complete      = false
    end

    def complete?
      @complete
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
      patient = Patient.new(
        '不明',
        '不明',
        '不明',
        '不明',
        '不明'
      )
      new_receipt(Receipt.new(
        '不明',
        patient,
        '____',
        '',
        @hospital || Hospital.new([] * 10)
      ))
    end

    # @param [CalcUnit] unit
    def new_unit(unit)
      close_current_unit
      @unit = unit
    end

    # @param [Integer] receipt_seq
    def update_seq_condition(receipt_seq)
      if @seqs.empty? && @walked_seqs.length.nonzero?
        @seq_condition = false
        @complete      = true
        return
      end

      if @seqs.empty?
        @seq_condition = true
        return
      end

      if (idx = @seqs.find_index { | s | s == receipt_seq })
        @walked_seqs.push(@seqs.at(idx))
        @seqs.delete_at(idx)
        @seq_condition = true
        return
      end

      @seq_condition = false
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
