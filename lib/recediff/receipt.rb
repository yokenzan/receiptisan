module Recediff
  # レセプト
  class Receipt
    # @param [Integer] id
    # @param [Integer] patient_id
    # @param [String] patient_name
    def initialize(id, patient_id, patient_name, code_of_types, tokki_jiko, hospital)
      @id           = id.to_i
      @patient_id   = patient_id.to_i
      @patient_name = $MASK ?
        sprintf('患者　%s', @patient_id.to_s.tr('0-9', '０-９')) :
        patient_name
      @units        = []
      @hokens       = []
      @syobyos      = []
      @type         = ReceiptType.new(code_of_types)
      @tokki_jiko   = tokki_jiko
      @hospital     = hospital
    end

    # @return [Boolean]
    def diff?
      total_point != point
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
        text << "## 保険者番号 %8s 請求点数 %d点 請求点数と算出合計点数一致？ %s\n" % [hoken.at(HOKEN::HOKENJA_NUMBER), total_point, point == total_point]
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

    def to_preview
      units.map(&:to_preview)
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
        # receipt_id, hoken_kohi_type, hoken_multiple_type, age_type, patient_id, hobetsu_list, iho, kohi_1, kohi_2, kohi_3, kohi_4,
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
      @hospital.seikyu_ym
    end

    def remove_comment_only_units
      @units.reject!(&:comment_only?)
    end

    attr_reader :units, :patient_id, :patient_name, :tokki_jiko

    class ReceiptType
      @@hoken_multiple_types = {
        :'1' => '単独',
        :'2' => '２併',
        :'3' => '３併',
        :'4' => '４併',
        :'5' => '５併',
      }
      @@age_types = {
        :'1' => '本入',
        :'2' => '本外',
        :'3' => '六入',
        :'4' => '六外',
        :'5' => '家入',
        :'6' => '家外',
        :'7' => '高入一',
        :'8' => '高外一',
        :'9' => '高入７',
        :'0' => '高外７',
      }
      def initialize(code_of_types)
        @code_of_types = code_of_types.to_s
      end

      def hoken_kohi_type
        @code_of_types[1]
      end

      def hoken_multiple_type
        @@hoken_multiple_types[@code_of_types[2].intern]
      end

      def age_type
        @@age_types[@code_of_types[3].intern]
      end
    end
  end
end
