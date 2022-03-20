# frozen_string_literal: true

module Recediff
  # rubocop:disable Metrics/ClassLength
  class Previewer
    attr_writer :color

    MIN_WIDTH = 50

    # @param [String?] global_interior
    def initialize(global_interior = nil)
      @width           = MIN_WIDTH
      @templates       = {}
      @current_shinku  = nil
      @current_receipt = nil
      @color           = false
      @printer         = nil
      @global_interior = global_interior
      @preview_methods = {
        Array:       proc { | object, _, _ | object.each_with_index { | c, idx | preview(c, idx) } },
        Receipt:     proc { | object, index, _ | preview_receipt(object, index) },
        Iho:         proc { | object, index, _ | preview_iho(object, index) },
        Kohi:        proc { | object, index, _ | preview_kohi(object, index) },
        Patient:     proc { | object, index, _ | preview_patient(object, index) },
        Syobyo:      proc { | object, index, _ | preview_disease(object, index) },
        CalcUnit:    proc { | object, index, _ | preview_calc_unit(object, index) },
        Cost:        proc { | object, index, shinku | preview_cost(object, index, shinku) },
        Comment:     proc { | object, index, shinku | preview_comment(object, index, shinku) },
        CommentCore: proc { | object, index, shinku | preview_comment(object, index, shinku) },
      }
    end

    def preview(object, index = nil, shinku = nil)
      @printer ||= @color ? DecoratablePrinter.new(@global_interior) : Printer.new
      @preview_methods
        .fetch(object.class.to_s.gsub(/.*:/, '').intern)
        .call(object, index, shinku)
    end

    private

    # param [Receipt] receipt
    # @param [Integer?] _index
    def preview_receipt(receipt, _index)
      @current_receipt = receipt
      @current_shinku  = nil

      puts '---*---*---*---*---*' * 6

      preview_receipt_header(receipt)

      unless receipt.patient.empty?
        preview(receipt.patient)
        puts '--------------------' * 6
      end

      unless receipt.hokens.empty?
        preview(receipt.hokens)
        puts '--------------------' * 6
      end

      unless receipt.diseases.empty?
        preview(receipt.diseases)
        puts '--------------------' * 6
      end

      preview(receipt.units) unless receipt.units.empty?

      puts "\n"
    end

    def preview_receipt_header(receipt)
      return if receipt.empty_header?

      puts '[No.%s] | %s%s / %s%s' % [
        @printer.decorate(receipt.id.zero? ? '不明' : '%4d' % receipt.id, 1),
        receipt.shinryo_ym.to_s.sub('-', '.'),
        receipt.shinryo_ym ? '診療' : '',
        receipt.seikyu_ym.to_s.sub('-', '.'),
        receipt.seikyu_ym ? '請求' : '',
      ]
      puts '種     別 | %s' % [receipt.type.to_detail]
      puts '特     記 | %s' % [receipt.tokki_jikos.map { | t | "[#{t}]" }.join(' ')]
    end

    # @param [Patient] patient
    # @param [Integer?] _index
    def preview_patient(patient, _index)
      birthday_and_age = patient.aged? ?
        '%s生 (%d歳%2dか月)' % [
          patient.birthday.strftime('%Y.%m.%d'),
          patient.age_of(@current_receipt.seikyu_ym),
          patient.age_month_of(@current_receipt.seikyu_ym),
        ] :
        ''
      puts '%s %s %s %s %s' % [
        patient.id,
        patient.name,
        patient.name_kana ?
          '(%s)' % @printer.decorate(patient.name_kana, 38, 5, 59) :
          '',
        patient.sex == 1 ?
          @printer.decorate('男', 36) :
          @printer.decorate('女', 35),
        birthday_and_age,
      ]
    end

    # @param [Iho] iho
    # @param [Integer?] _index
    def preview_iho(iho, _index)
      puts ' 医保     | %8s %8s点 %8s%s' % [
        iho.hokenja_bango,
        int2money(iho.point),
        futankin = int2money(iho.futankin),
        futankin.empty? ? '' : '円',
      ]
    end

    # @param [Kohi] kohi
    def preview_kohi(kohi, index)
      parened_futankin      = kohi.gairai_futankin
      parened_futankin_text = parened_futankin.nil? ?
        '' :
        '(%8s%s)' % [int2money(parened_futankin), '円']
      puts ' 公費%d    | %8s %8s点 %8s%s %s' % [
        index,
        kohi.futansha_bango,
        int2money(kohi.point),
        futankin = int2money(kohi.futankin),
        futankin.empty? ? '' : '円',
        parened_futankin_text,
      ]
    end

    # @param [Calcunit] calc_unit
    def preview_calc_unit(calc_unit, _index)
      calc_unit.each_with_index { | c, idx | preview(c, idx, calc_unit.shinku) }
      @current_shinku = calc_unit.shinku
    end

    # @param [Cost] cost
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    def preview_cost(cost, index, shinku = nil)
      return unless cost.name

      width           = MIN_WIDTH
      formatted_name  = format_text(cost.name)
      amount_text     = cost.amount? ? cost.amount : ''
      text_width      = displayed_width(formatted_name)
      total_width     = text_width + (cost.amount? ? displayed_width(amount_text) + 1 : 0)
      padder          = total_width >= width ? '' : ' ' * (width - total_width)
      point_and_count = cost.point.nil? ?
        '' :
        '%8s x %2s' % [int2money(cost.point), cost.count]
      color_sequence  = { IY: 14, SI: 15, TO: 13 }[cost.category.intern]
      text            = '%s | %s | %s%s%s%s' % [
        @printer.decorate(cost.code, 38, 5, 59),
        @current_shinku != shinku && index.zero? ?
          @printer.decorate('%02d' % shinku, '4:4') :
          '  ',
        @printer.decorate(index.zero? ? '＊' : '　', 1, 35),
        @printer.decorate(formatted_name, 38, 5, color_sequence),
        cost.amount? ? ' ' + @printer.decorate(amount_text, '4:4', '33') : '',
        padder,
      ]

      if total_width > width
        text << "\n"
        text << '%s | %s | %s' % [
          ' ' * 9,
          ' ' * 2,
          ' ' * (width + 2),
        ]
      end

      text << point_and_count
      text << @printer.decorate(' (%s)' % cost.done_at.join(', '), 38, 5, 24) unless cost.point.nil?

      puts text

      cost.comments.each { | c | preview_comment(c) } unless cost.comments.empty?
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    # @param [Syobyo] disease
    def preview_disease(disease, _index)
      width          = MIN_WIDTH
      main_state     = disease.main? ? '（主）' : ''
      formatted_name = format_text(main_state + disease.name)
      formatted_name = @printer.decorate_over(formatted_name, '4:3', 3, '58:5:46') if disease.worpro?
      formatted_name = @printer.decorate_over(formatted_name, 1, 31)               if disease.main?
      padder         = displayed_width(main_state + disease.name) < width ?
        ' ' * (width - displayed_width(main_state + disease.name)) :
        ''
      code_text      = @printer.decorate('%07d' % disease.code, 38, 5, 59)
      text           = '%s   | %s%s' % [code_text, formatted_name, padder]

      if displayed_width(main_state + disease.name) > width
        text << "\n"
        text << "%7s   | %#{width}s" % [' ', ' ']
      end

      text << disease.start_date
      text << ' ' << @printer.decorate(disease.tenki, disease.tenki_code + 30)

      puts text
    end

    # @param [Comment, CommentCore] comment
    # @param [Integer?] index
    # @param [Integer?] shinku
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    def preview_comment(comment, index = nil, shinku = nil)
      formatted_text            = format_text(comment.text)
      formatted_additional_text = comment.additional_text ?
        format_text(comment.additional_text) :
        ''
      puts '%s | %s | %s%s%s' % [
        @printer.decorate(comment.code, 38, 5, 59),
        shinku && @current_shinku != shinku && index && index.zero? ?
          @printer.decorate('%02d' % shinku, '4:4') :
          '  ',
        @printer.decorate(index && index.zero? ? '＊' : '　', 1, 35),
        @printer.decorate(formatted_text, 33, 2),
        comment.additional_text ?
          @printer.decorate(formatted_additional_text, 33, 2, 3, '4:2') :
          '',
      ]
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

    # @param [String] text
    # @return [String]
    def format_text(text)
      text.gsub('−', '－')
    end

    # @param [Integer?] int
    # @return [String]
    def int2money(int)
      int.nil? ? '' : int.to_s.gsub(/(?<=\d)(\d{3})/, ',\\1')
    end

    # @param [String] str
    # @return [Integer]
    def displayed_width(str)
      str.each_char.map { | c | c.bytesize == 1 ? 1 : 2 }.inject(0, &:+)
    end
  end
  # rubocop:enable Metrics/ClassLength

  class DecoratablePrinter
    def initialize(global_interior)
      @global_interior = global_interior
    end

    def decorate(text, *sequences)
      '%s%s%s%s' % [
        clear_interior,
        e(*sequences),
        text,
        clear_interior,
      ]
    end

    def decorate_over(text, *sequences)
      '%s%s%s' % [
        e(*sequences),
        text,
        clear_interior,
      ]
    end

    private

    def clear_interior
      clear_command = e(0)
      clear_command << @global_interior if @global_interior
      clear_command
    end

    def e(*sequences)
      "\e[#{sequences.map(&:to_s).join(';')}m"
    end
  end

  class Printer
    def decorate(text, *_sequences)
      text
    end

    alias decorate_over decorate
  end
end
