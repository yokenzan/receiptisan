# frozen_string_literal: true

module Recediff
  class SummaryParser
    include Recediff::Model::Uke

    # @param [String] uke_file_path
    # @return [UkeSummary]
    def parse_as_uke_receipts(uke_file_path)
      # @type [Array<ReceiptSourceSummary>] receipts
      receipts = []
      # @type [ReceiptSourceSummary?] receipt
      receipt  = nil
      # @type [HospitalSummary?] hospital
      hospital = nil

      File.foreach(uke_file_path, encoding: 'Windows-31J:UTF-8') do | row |
        case row[0, 2].intern
        when Recediff::Model::Uke::Enum::IR::RECORD
          hospital = parse_hospital_summary(row)
        when Recediff::Model::Uke::Enum::RE::RECORD
          receipts << receipt if receipt
          receipt = parse_into_receipt_summary(row, hospital)
          receipt.add(row)
        else
          receipt.add(row)
        end
      end

      UkeSummary.new(hospital, receipts)
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

    def parse_into_receipt_summary(row, hospital)
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
