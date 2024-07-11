# frozen_string_literal: true

module Recediff
  class SummaryParser
    include Recediff::Model::Uke

    def initialize
      clear
    end

    def clear
      # @type [Array<ReceiptSourceSummary>] receipts
      @receipts   = []
      # @type [HospitalSummary?] hospital
      @hospital   = nil
      # @type [ReceiptSourceSummary?] receipt
      @receipt    = nil
      # @type [Integer?] start_line
      @start_line = nil
    end

    # @param [String] uke_file_path
    # @return [UkeSummary]
    def parse_as_receipt_summaries(uke_file_path)
      clear

      File.foreach(uke_file_path, encoding: 'Windows-31J:UTF-8').with_index do | row, idx |
        parse_each_row(row, idx)
      end

      UkeSummary.new(hospital, receipts)
    end

    # @param [String] text
    # @return [UkeSummary]
    def parse_as_receipt_summaries_from_text(text)
      clear

      text.encode!(Encoding::UTF_8) unless text.encoding == Encoding::UTF_8
      text.each_line.with_index { | row, idx | parse_each_row(row, idx) }

      UkeSummary.new(@hospital, @receipts)
    rescue ArgumentError => e
      raise e unless e.message.include?('invalid byte sequence in UTF-8')

      text.force_encoding(Encoding::Shift_JIS).encode!(Encoding::UTF_8, Encoding::Shift_JIS)
      retry
    end

    def parse_each_row(row, idx)
      case row[0, 2].intern
      when Recediff::Model::Uke::Enum::IR::RECORD
        @hospital = parse_hospital_summary(row)
      when Recediff::Model::Uke::Enum::RE::RECORD
        # close current receipt
        if @receipt
          @receipt.source_line_range = @start_line..idx - 1
          @receipts << @receipt
        end
        # open new receipt
        @receipt    = parse_receipt_summary(row, @hospital)
        @start_line = idx
        @receipt.add(row)
      else
        @receipt.add(row)
      end
    end

    def parse_hospital_summary(row)
      columns = row.split(',')

      HospitalSummary.new(
        columns.at(Recediff::Model::Uke::Enum::IR::C_医療機関コード),
        columns.at(Recediff::Model::Uke::Enum::IR::C_都道府県),
        columns.at(Recediff::Model::Uke::Enum::IR::C_医療機関名称),
        columns.at(Recediff::Model::Uke::Enum::IR::C_請求年月),
        columns.at(Recediff::Model::Uke::Enum::IR::C_審査支払機関).to_i,
        row
      )
    end

    def parse_receipt_summary(row, hospital)
      columns = row.split(',')

      ReceiptSourceSummary.new(
        columns.at(Recediff::Model::Uke::Enum::RE::C_レセプト番号).to_i,
        columns.at(Recediff::Model::Uke::Enum::RE::C_レセプト種別),
        columns.at(Recediff::Model::Uke::Enum::RE::C_診療年月).to_i,
        columns.at(Recediff::Model::Uke::Enum::RE::C_氏名),
        columns.at(Recediff::Model::Uke::Enum::RE::C_カルテ番号等),
        hospital
      )
    end
  end
end