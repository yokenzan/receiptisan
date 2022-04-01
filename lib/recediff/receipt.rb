# frozen_string_literal: false

require 'month'
require 'erb'

module Recediff
  # レセプト
  class Receipt
    RE = Model::Uke::Enum::RE

    @@tokki_jikos = {
      '01': '公',
      '02': '長',
      '03': '長処',
      '04': '後保',
      '07': '老併',
      '08': '老健',
      '09': '施',
      '10': '第三',
      '11': '薬治',
      '12': '器治',
      '13': '先進',
      '14': '制超',
      '16': '長２',
      '20': '二割',
      '21': '高半',
      '25': '出産',
      '26': '区ア',
      '27': '区イ',
      '28': '区ウ',
      '29': '区エ',
      '30': '区オ',
      '31': '多ア',
      '32': '多イ',
      '33': '多ウ',
      '34': '多エ',
      '35': '多オ',
      '36': '加治',
      '37': '申出',
      '38': '医併',
      '39': '医療',
    }

    # @param [Integer] id
    # @param [Patient] patient
    # @param [String] code_of_types
    # @param [String?] tokki_jiko
    # @param [Hospital] hospital
    def initialize(id, patient, code_of_types, tokki_jiko, hospital, row = [])
      @id           = id.to_i
      @patient_id   = patient_id.to_i
      @patient      = patient
      @units        = []
      @hokens       = []
      @syobyos      = []
      @type         = ReceiptType.new(code_of_types)
      @tokki_jiko   = tokki_jiko
      @hospital     = hospital
      @row          = row
    end

    # @return [Boolean]
    def diff?
      total_point != point
    end

    def empty_header?
      [@type, @patient, @tokki_jiko, @hospital].all?(&:empty?)
    end

    def shinryo_ym
      raw_value = @row.at(RE::C_診療年月)
      raw_value.nil? || raw_value.empty? ?
        nil :
        Month.new(
          raw_value[0,  4].to_i,
          raw_value[-1, 2].to_i
        )
    end

    def diseases
      @syobyos
    end

    # @param [CalcUnit] unit
    def add_unit(unit)
      @units << unit
    end

    def add_hoken(hoken)
      @hokens << hoken
    end

    def add_syobyo(row)
      @syobyos << row
    end

    # @return [Array<String>, nil]
    def hoken
      @hokens.first
    end

    # @return self
    def reinitialize
      remove_comment_only_units
      @units.each(&:reinitialize)
      self
    end

    # @return self
    def sort!
      @units.sort_by!(&:uniq_id)
      self
    end

    # @return [Array<Integer>]
    def days
      @units.map(&:done_at).flatten.uniq.sort
    end

    # @return [Integer]
    def total_point
      hoken.at(HOKEN::TOTAL_POINT)&.to_i
    end

    def lower_kubun
      @row.at(RE::C_一部負担金・食事療養費・生活療養費標準負担額区分)
    end

    def show
      text = ''
      # text << "\n#### %5d - %s ########\n" % [@patient_id, @patient_name]
      text << "\n#### %5d - %s - %d点 ########\n" % [@patient_id, @patient_name, point]

      text << show_meisai
      text << "\n--------------------------------\n"
      text << show_syobyo
      text
    end

    def show_meisai
      text = ''
      text << "\n\n"

      if total_point
        parameters = [hoken.at(HOKEN::HOKENJA_NUMBER), total_point, point == total_point]
        format     = "## 保険者番号 %8s 請求点数 %d点 請求点数と算出合計点数一致？ %s\n"
        text << format % parameters
      end

      days.each do | d |
        # @type [Array<CalcUnit>] units
        # @type [CalcUnit] u
        units = @units.select { | u | u.done_at?(d) }

        text << "\n### %2d日 %d点-----\n" % [d, units.sum { | u | u.point_at(d) }]
        # @type [CalcUnit] u
        text << units.map { | u | u.show(d) }.join("\n")
      end

      text
    end

    def show_syobyo
      @syobyos.sort_by(&:code).map { | s | s.to_list(patient_id) }.join("\n")
    end

    # @return [Integer]
    def point
      days.sum { | d | @units.select { | u | u.done_at?(d) }.sum { | u | u.point_at(d) } }
    end

    def to_csv(sep = ',')
      hospital_columns = [
        @hospital.prefecture_code,
        @hospital.code,
        @hospital.shaho_or_kokuho,
        @hospital.seikyu_ym,
      ]
      receipt_level_columns = [
        @id,
        @type.hoken_kohi_type,
        @type.hoken_multiple_type,
        @type.age_type,
        patient_id,
        patient_name,
        # nil,
        # nil,
        # nil,
        # nil,
        # nil,
        # nil,
      ]
      units.map.with_index do | cu, cu_order |
        # hospital_code, year_month, kikin_or_kokuho,
        # receipt_id, hoken_kohi_type, hoken_multiple_type, age_type,
        # patient_id, hobetsu_list, iho, kohi_1, kohi_2, kohi_3, kohi_4,
        # calc_unit_order, cost_order, receden_code, name, count, point
        cu_point = cu.point
        cu_count = cu.count
        cu.map.with_index do | cost, cost_order |
          header = hospital_columns + receipt_level_columns
          [(header + [
            cu_order,
            cu.shinku,
            cu_point,
            cu_count,
            cost_order,
            cost.category,
            cost.code,
            cost.name,
            cost.count,
            cost.code_table_upper_category,
            cost.code_table_lower_category,
            cost.code_table_number,
          ]).join(sep)].concat(
            cost.comments.map do | comment |
              (header + [
                cu_order,
                cu.shinku,
                cu_point,
                cu_count,
                cost_order,
                cost.category + '(CO)',
                comment.code,
                comment.name,
                comment.count,
                comment.code_table_upper_category,
                comment.code_table_lower_category,
                comment.code_table_number,
              ]).join(sep)
            end
          ).flatten(1)
        end.join("\n")
      end.join("\n")
    end

    def seikyu_ym
      @hospital&.seikyu_ym ?
        Month.new(@hospital.seikyu_ym[0, 4].to_i, @hospital.seikyu_ym[-1, 2].to_i) :
        nil
    end

    def remove_comment_only_units
      @units.reject!(&:comment_only?)
    end

    def tokki_jikos
      tokki_jiko.to_s.scan(/.{2}/).map { | code | '%s%s' % [code, @@tokki_jikos[code.intern]] }
    end

    attr_reader :units, :patient_id, :patient_name, :tokki_jiko, :patient, :type, :id, :hokens, :hospital

    class ReceiptType
      class << self
        attr_reader :hoken_multiple_types, :age_types, :ika_types, :shuhoken_types
      end

      @ika_types = {
        _:   '不明',
        '1': '医科',
        '3': '歯科',
      }

      @shuhoken_types = {
        _:   '不明',
        '1': '医保',
        '2': '公費',
        '3': '後期',
        '4': '退職',
      }

      @hoken_multiple_types = {
        _:   '不明',
        '1': '単独',
        '2': '２併',
        '3': '３併',
        '4': '４併',
        '5': '５併',
      }
      @age_types = {
        _:   '不明',
        '1': '本入',
        '2': '本外',
        '3': '六入',
        '4': '六外',
        '5': '家入',
        '6': '家外',
        '7': '高入一',
        '8': '高外一',
        '9': '高入７',
        '0': '高外７',
      }

      def initialize(code_of_types)
        @code_of_types = code_of_types.to_s
      end

      def ika_type_code
        @code_of_types[0]
      end

      def shuhoken_type_code
        @code_of_types[1]
      end

      def hoken_multiple_type_code
        @code_of_types[2]
      end

      def age_type_code
        @code_of_types[3]
      end

      def ika_type
        self.class.ika_types[@code_of_types[0].intern]
      end

      def hoken_multiple_type
        self.class.hoken_multiple_types[@code_of_types[2].intern]
      end

      def shuhoken_type
        self.class.shuhoken_types[@code_of_types[1].intern]
      end

      def age_type
        self.class.age_types[@code_of_types[3].intern]
      end

      def to_s
        @code_of_types
      end

      def empty?
        @code_of_types == '____'
      end

      def to_detail
        [
          ika_type_code,
          ika_type,
          shuhoken_type_code,
          shuhoken_type,
          hoken_multiple_type_code,
          hoken_multiple_type,
          age_type_code,
          age_type,
        ].each_slice(2).map { | c, s | '[%s %s]' % [c, s] }.join(' ')
      end
    end
  end
end
