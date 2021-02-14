module Recediff
  # レセプト
  class Receipt
    # @param [Integer] id
    # @param [Integer] patient_id
    # @param [String] patient_name
    def initialize(id, patient_id, patient_name)
      @id           = id.to_i
      @patient_id   = patient_id.to_i
      @patient_name = patient_name
      @units        = []
      @hokens       = []
    end

    def diff?
      total_point != point
    end

    def add_unit(calc_unit)
      @units << calc_unit
    end

    def add_hoken(hoken)
      @hokens << hoken
    end

    def hoken
      @hokens.first
    end

    def sort!
      @units.sort_by!(&:uniq_id)
      self
    end

    def days
      @units.map(&:done_at).flatten.uniq.sort
    end

    def total_point
      hoken.at(HOKEN::TOTAL_POINT)&.to_i
    end

    def show
      text = ''
      text << "\n#### %5d - %s - %d点 ########\n" % [@patient_id, @patient_name, point]
      text << "\n\n"
      if total_point
        text << "## 保険者番号 %8s 請求点数 %d点 請求点数と算出合計点数一致？ %s\n" % [hoken.at(HOKEN::HOKENJA_NUMBER), total_point, point == total_point]
      end
      days.each do | d |
        units = @units.select { | u | u.done_at?(d) }

        text << "\n### %2d日 %d点-----\n" % [d, units.sum(&:point)]
        text << units.
          map.with_index { | u, index | u.show(d) }.
          join("\n")
      end
      text
    end

    def point
      days.sum do | d |
        @units.select { | u | u.done_at?(d) }.sum { | u | u.point_at(d) }
      end
    end

    attr_reader :units, :patient_id
  end
end
