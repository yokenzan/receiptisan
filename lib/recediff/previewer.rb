# frozen_string_literal: true

module Recediff
  # rubocop:disable Metrics/ClassLength
  class Previewer
    attr_writer :color

    MIN_WIDTH = 50

    # @param [String?] global_interior
    def initialize(options = {}, global_interior = nil)
      @width           = MIN_WIDTH
      @templates       = {}
      @current_shinku  = nil
      @current_receipt = nil
      @printer         = nil
      @util            = StringUtil.new
      @options         = options
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
      @printer ||= @options[:color] ? DecoratablePrinter.new : Printer.new
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

      preview_header_section
      preview_patient_section
      preview_hoken_section
      preview_disease_section
      preview_content_section

      puts "\n"
    end

    def preview_header_section
      return unless @options[:header]
      return if @current_receipt.empty_header?

      preview_receipt_header
    end

    def preview_patient_section
      return if @current_receipt.patient.empty?

      preview(@current_receipt.patient)
      puts '--------------------' * 6
    end

    def preview_hoken_section
      return unless @options[:hoken]
      return if @current_receipt.hokens.empty?

      preview(@current_receipt.hokens)
      puts '--------------------' * 6
    end

    def preview_disease_section
      return unless @options[:disease]
      return if @current_receipt.diseases.empty?

      preview(@current_receipt.diseases)

      @printer.global_interior = nil

      puts '--------------------' * 6
    end

    def preview_content_section
      return unless @options[:calcunit]
      return if @current_receipt.units.empty?

      preview(@current_receipt.units)
    end

    def preview_receipt_header
      puts '[No.%s] | %s%s / %s%s' % [
        @printer.bold.decorate(@current_receipt.id.zero? ? '不明' : '%4d' % @current_receipt.id),
        @current_receipt.shinryo_ym.to_s.sub('-', '.'),
        @current_receipt.shinryo_ym ? '診療' : '',
        @current_receipt.seikyu_ym.to_s.sub('-', '.'),
        @current_receipt.seikyu_ym ? '請求' : '',
      ]
      puts '種     別 | %s  %s' % [
        @current_receipt.type.to_detail,
        { '1': 'Ⅱ', '2': 'Ⅱ超', '3': 'Ⅰ', '4': 'Ⅰ老' }[@current_receipt.lower_kubun.to_s.intern],
      ]
      puts '特     記 | %s' % @current_receipt.tokki_jikos.map { | t | "[#{t}]" }.join(' ')
    end

    # @param [Patient] patient
    # @param [Integer?] _index
    def preview_patient(patient, _index)
      birthday_and_age = patient.aged? && @current_receipt.shinryo_ym ?
        '%s生 (%d歳%2dか月)' % [
          patient.birthday.strftime('%Y.%m.%d'),
          patient.age_of(@current_receipt.shinryo_ym),
          patient.age_month_of(@current_receipt.shinryo_ym),
        ] :
        ''
      sex = patient.sex.to_s.intern
      puts '%s %s %s %s %s' % [
        patient.id,
        mask_name(patient.name),
        patient.name_kana ?
          '(%s)' % @printer.fg_color(index: 59).decorate(mask_name(patient.name_kana)) :
          '',
        @printer.fg_color(name: { '1': :cyan, '2': :magenta }[sex]).decorate({ '1': '男', '2': '女' }[sex]),
        birthday_and_age,
      ]
    end

    # @param [Iho] iho
    # @param [Integer?] _index
    def preview_iho(iho, _index)
      puts ' 医保     | %8s  %2d日 %8s点 %8s%s' % [
        mask_bango(iho.hokenja_bango),
        iho.day_count,
        @util.int2money(iho.point),
        futankin = @util.int2money(iho.futankin),
        futankin.empty? ? '' : '円',
      ]
    end

    # @param [Kohi] kohi
    def preview_kohi(kohi, index)
      parened_futankin      = kohi.gairai_futankin
      parened_futankin_text = parened_futankin.nil? ?
        '' :
        '(%8s%s)' % [@util.int2money(parened_futankin), '円']
      puts ' 公費%d    | %8s  %2d日 %8s点 %8s%s %s' % [
        index,
        mask_bango(kohi.futansha_bango),
        kohi.day_count,
        @util.int2money(kohi.point),
        futankin = @util.int2money(kohi.futankin),
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
      # return unless cost.name

      cost_name       = cost.name || '  (＊＊＊表示不可＊＊＊)  '
      width           = MIN_WIDTH
      formatted_name  = @util.format_text(cost_name)
      amount_text     = generate_amount(cost)
      text_width      = @util.displayed_width(formatted_name)
      total_width     = text_width + (cost.amount? ? @util.displayed_width(amount_text) + 1 : 0)
      padder          = total_width >= width ? '' : ' ' * (width - total_width)
      color_sequence  = { IY: 14, SI: 15, TO: 13 }[cost.category.intern]
      text            = '%s | %s | %s%s%s%s' % [
        @printer.fg_color(index: 59).decorate(cost.code),
        @current_shinku != shinku && index.zero? ?
          @printer.underline(style: :dotted).decorate('%02d' % shinku) :
          '  ',
        @printer.bold.fg_color(name: :magenta).decorate(index.zero? ? '＊' : '　'),
        @printer.fg_color(index: color_sequence).decorate(
          { IY: '💊', SI: '💪', TO: '⚙️' }[cost.category.intern] + formatted_name
        ),
        cost.amount? ?
          ' ' + @printer
            .underline(style: :dotted)
            .fg_color(name: :yellow)
            .decorate(amount_text) :
          '',
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

      text << generate_point_and_count(cost)
      text << @printer.fg_color(index: 24).decorate(' (%s)' % cost.done_at.join(', ')) unless cost.point.nil?

      puts text

      cost.comments.each { | c | preview_comment(c) } unless cost.comments.empty?
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    # @param [Syobyo] disease
    # @param [Integer] index
    def preview_disease(disease, index)
      @printer.global_interior = index.even? ? "\e[48;5;235m" : ''

      width          = MIN_WIDTH
      main_state     = disease.main? ? '（主）' : ''
      disease_text   = main_state + disease.name
      disease_length = @util.displayed_width(disease_text)
      formatted_name = @util.format_text(disease_text)
      disease.worpro? && formatted_name = @printer
        .underline(style: :curly, color: { index: 46 })
        .italic
        .decorate_over(formatted_name)
      disease.main? && formatted_name = @printer
        .bold.fg_color(name: :red)
        .decorate_over(formatted_name)
      padder         = disease_length < width ? ' ' * (width - disease_length) : ''
      code_text      = @printer.fg_color(index: 59).decorate('%07d' % disease.code)
      text           = '%s   | %s%s' % [code_text, formatted_name, padder]

      if disease_length > width
        text << "\n"
        text << "%7s   | %#{width}s" % [' ', ' ']
      end

      text << disease.start_date.strftime('%Y.%m.%d')
      text << ' '
      text << @printer.fg_color(index: disease.tenki_code).decorate(disease.tenki)
      text << ' ' * 2
      text << @printer.clear
      puts text
    end

    # @param [Comment, CommentCore] comment
    # @param [Integer?] index
    # @param [Integer?] shinku
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    def preview_comment(comment, index = nil, shinku = nil)
      formatted_text            = @util.format_text(comment.text)
      formatted_additional_text = comment.additional_text ?
        @util.format_text(comment.additional_text) :
        ''
      puts '%s | %s | %s%s%s' % [
        @printer.fg_color(index: 59).decorate(comment.code),
        shinku && @current_shinku != shinku && index && index.zero? ?
          @printer.underline(style: :dotted).decorate('%02d' % shinku) :
          '  ',
        @printer
          .bold
          .fg_color(name: :magenta)
          .decorate(index && index.zero? ? '＊' : '　'),
        @printer.dim.fg_color(name: :yellow).decorate('📑' + formatted_text),
        comment.additional_text ?
          @printer
            .fg_color(name: :yellow)
            .dim
            .italic
            .underline(style: :double)
            .decorate(formatted_additional_text) :
          '',
      ]
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity

    # @param [Cost] cost
    def generate_amount(cost)
      return '' unless cost.amount?

      cost.amount_is_int? ? @util.int2money(cost.amount) : cost.amount.to_f.to_s
    end

    # @param [Cost] cost
    def generate_point_and_count(cost)
      cost.point.nil? ? '' : '%8s x %2s' % [@util.int2money(cost.point), cost.count]
    end

    # @return [Boolean]
    def mask?
      @options[:mask]
    end

    # @param [String] name
    # @return [String]
    def mask_name(name)
      mask? ? @util.mask_name(name) : name
    end

    # @param [String] bango
    # @return [String]
    def mask_bango(bango)
      mask? ? @util.mask_bango(bango) : bango
    end
  end
  # rubocop:enable Metrics/ClassLength

  class StringUtil
    # @param [String] text
    # @return [String]
    def format_text(text)
      text.gsub('−', '－')
    end

    # @param [Integer?] int
    # @return [String]
    def int2money(int)
      int.nil? ? '' : int.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
    end

    # @param [String] str
    # @return [Integer]
    def displayed_width(str)
      str.each_char.map { | c | c.bytesize == 1 ? 1 : 2 }.inject(0, &:+)
    end

    # @param [String] name
    # @return [String]
    def mask_name(name)
      name.sub(/^(.*)(.)/, '＊＊＊＊\2')
    end

    # @param [String] bango
    # @return [String]
    def mask_bango(bango)
      bango.gsub(/\d{4}\z/, '****')
    end
  end

  class Printer
    attr_writer :global_interior

    @@interior_builder_methods = %i[
      inverse
      strike_through
      fg_color
      bg_color
      colors_by_name
      underline_color
      colors_by_index
      underline
      overline
      on_interior
      bold
      dim
      italic
      build
      blink
      invisible
    ]

    def initialize(global_interior = nil)
      @global_interior = global_interior
    end

    def clear
      ''
    end

    def decorate(text)
      text
    end

    alias decorate_over decorate

    private

    def method_missing(method, **opts)
      super unless @@interior_builder_methods.include?(method)

      self
    end

    def respond_to_missing?(method, args)
      super unless @@interior_builder_methods.include?(method)
    end
  end

  class DecoratablePrinter < Printer
    def initialize(global_interior = nil)
      super(global_interior)
      @interior_builder = EscapeSequenceInteriorBuilder.new
    end

    def decorate(text)
      '%s%s%s%s' % [
        clear,
        @interior_builder.build,
        text,
        clear,
      ]
    end

    def decorate_over(text)
      '%s%s%s' % [
        @interior_builder.build,
        text,
        clear,
      ]
    end

    def clear
      @interior_builder.clear_interior
    end

    private

    def method_missing(method, **opts) # rubocop:disable Style/MissingRespondToMissing
      super unless @@interior_builder_methods.include?(method)

      @interior_builder.__send__(method, **opts)

      self
    end
  end
end
