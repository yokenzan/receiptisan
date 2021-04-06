# frozen_string_literal: true
require 'csv'

module Recediff
  class Parser
    # @param [Master]           master
    # @param [DiseaseMaster]    disease_master
    # @param [ShushokugoMaster] shushokugo_master
    def initialize(master, disease_master, shushokugo_master)
      @master            = master
      @disease_master    = disease_master
      @shushokugo_master = shushokugo_master
    end

    # @param [String] uke_file_path
    # @return [Array<Receipt>]
    def parse(uke_file_path)
      context = Context.new

      CSV.foreach(uke_file_path, encoding: 'Windows-31J:UTF-8') { | row | parse_row(row, context) }

      context.close_current_receipt

      context.receipts.each(&:sort!).sort_by(&:patient_id)
    end

    private

    def parse_row(row, context)
      case category = row.at(COST::CATEGORY)
      when /IR/
        context.hospital = Hospital.new(row)
      when /RE/
        context.new_receipt(
          Receipt.new(
            row.at(RE::RECEIPT_ID).to_i, row.at(RE::PATIENT_ID).to_i, row.at(RE::PATIENT_NAME), row.at(2), context.hospital
          )
        )
      when /HO/, /KO/
        context.receipt.add_hoken(row)
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

        context.receipt.add_syobyo(syobyo)
      when /SJ/, /GO/, /IR/
        ignore
      else
        add_cost(context, category, row)
      end
    end

    def add_cost(context, category, row)
      if shinku = row.at(COST::SHINKU)
        context.new_unit(CalcUnit.new(shinku.to_i))
      end
      return if comment?(category)

      context.unit.add_cost(
        Cost.new(code = row.at(COST::CODE).to_i, @master.find_name_by_code(code), category, row)
      )
    end

    def comment?(category)
      category =~ /CO/
    end

    def ignore; end

    class Context
      attr_reader :receipts, :receipt, :unit
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

        receipts << @receipt if @receipt
        @receipt = nil
      end

      # @param [CalcUnit] unit
      def new_unit(unit)
        close_current_unit
        @unit = unit
      end

      private

      def close_current_unit
        receipt.add_unit(unit.reinitialize.sort!) if has_unterminated_context?
        @unit = nil
      end

      def has_unterminated_context?
        receipt && unit && !unit.empty?
      end
    end
  end
end
