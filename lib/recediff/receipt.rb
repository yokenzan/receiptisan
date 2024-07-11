# frozen_string_literal: false

require 'month'
require 'erb'
require 'forwardable'

module Recediff
  # レセプト
  class Receipt
    extend Forwardable
    def_delegators :hospital, :shaho_or_kokuho

    RE = Model::Uke::Enum::RE

    @@tokki_jikos = {
      '01': '公　',
      '02': '長　',
      '03': '長処',
      '04': '後保',
      '07': '老併',
      '08': '老健',
      '09': '施　',
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
      '96': '災１',
      '97': '災２',
    }

    # @param [Integer] id
    # @param [Patient] patient
    # @param [String] code_of_types
    # @param [String?] tokki_jiko
    # @param [Hospital] hospital
    def initialize(id, patient, code_of_types, tokki_jiko, hospital, row = [])
      @id           = id.to_i
      @patient      = patient
      @units        = []
      @hokens       = []
      @syobyos      = []
      @type         = ReceiptType.new(code_of_types)
      @tokki_jiko   = tokki_jiko
      @hospital     = hospital
      @row          = row
    end

    def empty_header?
      [@type, @patient, @tokki_jiko, @hospital].all?(&:empty?)
    end

    # @return [Month, nil]
    def shinryo_ym
      raw_value = @row.at(RE::C_診療年月)
      raw_value.nil? || raw_value.empty? ?
        nil :
        Month.new(
          raw_value[0,  4].to_i,
          raw_value[-2, 2].to_i
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

    # @return [Iho, Kohi, nil]
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

    def lower_kubun
      @row.at(RE::C_一部負担金・食事療養費・生活療養費標準負担額区分)
    end

    def show
      lines = []
      birthday = patient.aged? && shinryo_ym ?  '%s生' %  patient.birthday.strftime('%Y-%m-%d') : ''
      age      = patient.aged? && shinryo_ym ?  '%d歳%2dか月' % [
          patient.age_of(shinryo_ym),
          patient.age_month_of(shinryo_ym),
        ] :
        ''
      lines << [
        '患者基本',
        "##{id}",
        patient.id,
        patient.name,
        birthday,
        age,
      ].join("\t")
      lines << show_syobyo
      lines << show_meisai

      lines.join("\n")
    end

    def show_meisai
      util  = StringUtil.new
      lines = []

      days.each do | d |
        # @type [Array<CalcUnit>] units
        # @type [CalcUnit] u
        units = @units.select { | u | u.done_at?(d) }
        date  = Date.new(shinryo_ym.year, shinryo_ym.number, d)
        lines << [
          '診療明細',
          "##{id}",
          patient.id,
          patient.name,
          '',
          '',
          '',
          '',
          "#{date.strftime('%Y-%m-%d')}(#{util.int2money(units.sum { | u | u.point_at(d) })}点)",
        ].join("\t")
        lines << units.map { | u | show_unit(u, d) }
      end

      lines.join("\n")
    end

    def show_syobyo
      @syobyos
        .sort_by { | s | [s.main?, s.start_date, s.code].map(&:to_s).join('-') }
        .map { | s | [
          '患者傷病',
          "##{id}",
          patient.id,
          patient.name,
          s.code,
          s.main_state_text + s.name,
          s.start_date,
          s.tenki,
          ].join("\t")
        }
        .join("\n")
    end

    # @param [CalcUnit] unit
    # @param [Integer] day
    # @return [String]
    def show_unit(unit, day)
      util  = StringUtil.new
      lines = []
      lines << [
        '診療明細',
        "##{id}",
        patient.id,
        patient.name,
        '',
        '',
        '',
        '',
        '',
        '診療識別%02d(%s点)' % [unit.shinku, util.int2money(unit.point_at(day))],
      ].join("\t")

      unit.map.with_index { | c, index | lines << [
        '診療明細',
        "##{id}",
        patient.id,
        patient.name,
        '',
        '',
        '',
        '',
        '',
        '',
        c.category,
        index + 1,
        c.code,
        c.name,
        c.amount,
        index == unit.length - 1 ? unit.point : '',
        c.is_a?(Cost) ? "x#{c.count_at(day)}" : '',
      ].join("\t") }

      lines.join("\n")
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
        @type.shuhoken_type,
        @type.hoken_multiple_type,
        @type.age_type,
        patient.id,
        patient.name,
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
            cost.amount,
            cost.count,
            cost.done_at.join(';'),
            # cost.code_table_upper_category,
            # cost.code_table_lower_category,
            # cost.code_table_number,
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
                # comment.code_table_upper_category,
                # comment.code_table_lower_category,
                # comment.code_table_number,
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

    def nyuin?
      @type.age_type_code.to_i.odd?
    end

    attr_reader :units, :tokki_jiko, :patient, :type, :id, :hokens, :hospital

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

      def to_details
        [
          ika_type_code,
          ika_type,
          shuhoken_type_code,
          shuhoken_type,
          hoken_multiple_type_code,
          hoken_multiple_type,
          age_type_code,
          age_type,
        ].each_slice(2).map { | c, s | [c, s] }
      end
    end
  end
end
