# frozen_string_literal: true

require 'csv'

module Recediff
  class Parser
    RE = Recediff::Model::Uke::Enum::RE

    class << self
      def create
        dir = __dir__
        new(
          Recediff::Master.load(dir + '/../../csv'),
          Recediff::DiseaseMaster.load(dir + '/../../csv'),
          Recediff::ShushokugoMaster.load(dir + '/../../csv'),
          Recediff::CommentMaster.load(dir + '/../../csv')
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
      options = { encoding: 'Windows-31J:UTF-8' }
      buffer  = Buffer.new(seqs, seqs.empty?)

      CSV.foreach(uke_file_path, **options) { | row | buffer.complete? ? break : parse_row(row, buffer) }

      buffer.close_current_receipt
      buffer.receipts
    end

    # @param [String] text
    def parse_area(text)
      text.encode!(Encoding::UTF_8) unless text.encoding == Encoding::UTF_8

      buffer    = Buffer.new
      first_row = text.split("\n").first

      buffer.new_empty_receipt if !receipt_row?(first_row) && !hospital_row?(first_row)

      CSV.parse(text) { | row | buffer.complete? ? break : parse_row(row, buffer) }

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

    # rubocop:disable Metrics/CyclomaticComplexity
    def parse_row(row, buffer)
      case category = row.first
      when /IR/
        buffer.hospital = Hospital.from_uke(row)
      when /RE/
        buffer.update_seq_condition(row.at(RE::C_レセプト番号).to_i)
        return if buffer.complete?

        new_receipt(row, buffer)
      when /HO/
        buffer.in_seq? && buffer.receipt.add_hoken(Iho.from_uke(row))
      when /KO/
        buffer.in_seq? && buffer.receipt.add_hoken(Kohi.from_uke(row))
      when /SY/
        add_syobyo(row, buffer)
      when /SJ/, /GO/, /SN/, nil
        ignore
      else
        add_cost(buffer, category, row)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def new_receipt(row, buffer)
      return unless buffer.in_seq?

      patient = Patient.from_uke(row)
      receipt = Receipt.new(
        row.at(RE::C_レセプト番号).to_i,
        patient,
        row.at(RE::C_レセプト種別),
        row.at(RE::C_レセプト特記事項),
        buffer.hospital,
        row
      )
      buffer.new_receipt(receipt)
    end

    def add_syobyo(row, buffer)
      return unless buffer.in_seq?

      code    = row.at(SYOBYO::CODE)
      name    = code.to_i == 999 ? row.at(SYOBYO::WORPRO_NAME) : @disease_master.find_name_by_code(code)
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

      column_headers = Recediff::Model::Uke::Enum.const_get(category)

      if (shinku = row.at(column_headers::C_診療識別))
        buffer.new_unit(CalcUnit.new(shinku.to_i))
      end

      unless comment?(category)
        cost = Cost.new(code = row.at(column_headers::C_レセ電コード).to_i, @master.find_by_code(code), category, row)
        row[column_headers::C_コメント_1_コメントコード..column_headers::C_コメント_3_文字データ]
          .each_slice(2)
          .reject { | c, _ | c.nil? }
          .each do | c, additional_text |
            comment_text = @comment_master.find_by_code(c.to_i)
            comment_core = CommentCore.new(c.to_i, comment_text, additional_text)
            cost.add_comment(Comment.new(comment_core, category, []))
          end
        buffer.unit.add_cost(cost)
      else
        code         = row.at(column_headers::C_レセ電コード).to_i
        comment_text = @comment_master.find_by_code(code.to_i)
        comment_core = CommentCore.new(code.to_i, comment_text, row.at(column_headers::C_文字データ))
        buffer.unit.add_cost(Comment.new(comment_core, category, row))
      end
    end

    def comment?(category)
      category =~ /CO/
    end

    def ignore; end
  end
end
