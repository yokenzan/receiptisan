# frozen_string_literal: true

module Recediff
  class EscapeSequenceInteriorBuilder # rubocop:disable Metrics/ClassLength
    class CommandStruct
      def initialize(*args)
        # @type [Array] @parameters
        @parameters = args
      end

      def to_command_code
        @parameters.join(':')
      end

      def <<(*args)
        @parameters.concat(args)
      end
    end

    INTERIOR_CLEAR                  = 0
    INTERIOR_BOLD                   = 1
    INTERIOR_DIM                    = 2
    INTERIOR_NORMAL                 = 22

    INTERIOR_ITALIC                 = 3
    INTERIOR_ITALIC_OFF             = 23

    INTERIOR_UNDERLINE              = 4
    INTERIOR_UNDERLINE_OFF          = 24 # unused

    INTERIOR_BLINK                  = 5
    INTERIOR_BLINK_RAPID            = 6
    INTERIOR_BLINK_OFF              = 25

    INTERIOR_INVERSE                = 7
    INTERIOR_INVERSE_OFF            = 27

    INTERIOR_INVISIBLE              = 8
    INTERIOR_INVISIBLE_OFF          = 28

    INTERIOR_STRIKE_THROUGH         = 9
    INTERIOR_STRIKE_THROUGH_OFF     = 29

    INTERIOR_OVERLINE               = 53
    INTERIOR_OVERLINE_OFF           = 54

    INTERIOR_COLOR_FG_BASE          = 30
    INTERIOR_COLOR_FG_EXTEND        = 38
    INTERIOR_COLOR_BG_BASE          = 40
    INTERIOR_COLOR_BG_EXTEND        = 48
    INTERIOR_COLOR_UNDERLINE_EXTEND = 58

    INTERIOR_COLOR_BY_RGB           = 2  # unused
    INTERIOR_COLOR_BY_INDEX         = 5
    INTERIOR_COLOR_BRIGHT_SLIDE     = 60

    @@underline_styles = {
      disabled: 0,
      single:   1,
      double:   2,
      curly:    3,
      dotted:   4,
      dashed:   5,
    }.freeze

    @@named_colors = {
      black:          0,
      red:            1,
      green:          2,
      yellow:         3,
      blue:           4,
      magenta:        5,
      cyan:           6,
      white:          7,
      bright_black:   8,
      bright_red:     9,
      bright_green:   10,
      bright_yellow:  11,
      bright_blue:    12,
      bright_magenta: 13,
      bright_cyan:    14,
      bright_white:   15,
    }.freeze

    def initialize
      clear_state
    end

    # @return self
    def clear_state
      # @type [Hash<Symbol, Array<CommandStruct>>] @options
      @options = {
        brightness: [],
        color:      [],
        underline:  [],
        overline:   [],
        other:      [],
      }
    end

    # @return [String]
    def build(preserve_state: false)
      return '' if empty?

      sequence = "\e[%sm" % @options
        .values
        .reject(&:empty?)
        .map { | commands | commands.map(&:to_command_code) }
        .join(';')

      clear_state unless preserve_state

      sequence
    end

    def empty?
      @options.each_value.all?(:empty?)
    end

    def on_interior(*interiors, **color_interiors)
      interiors&.each { | interior | __send__(interior.intern) }
      color_interiors&.each { | key, value | value.is_a?(Hash) ? __send__(key, **value) : __send__(key, value) }

      out = ''
      out << build
      yield out
      out << reset
      out
    end

    def clear_interior
      "\e[0m"
    end

    # @return self
    def bold(enabled: true)
      @options[:brightness] << (enabled ?
        CommandStruct.new(INTERIOR_BOLD) :
        CommandStruct.new(INTERIOR_NORMAL))

      self
    end

    def dim(enabled: true)
      @options[:brightness] << (enabled ?
        CommandStruct.new(INTERIOR_DIM) :
        CommandStruct.new(INTERIOR_NORMAL))

      self
    end

    # @return self
    def italic(enabled: true)
      @options[:other] << (enabled ?
        CommandStruct.new(INTERIOR_ITALIC) :
        CommandStruct.new(INTERIOR_ITALIC_OFF))

      self
    end

    # @return self
    def underline(enabled: true, style: :single)
      command =  CommandStruct.new(INTERIOR_UNDERLINE)
      command << (enabled ?
        @@underline_styles[style] :
        @@underline_styles[:disabled])

      @options[:underline] << command

      self
    end

    def overline(enabled: true)
      @options[:overline] << (enabled ?
        CommandStruct.new(INTERIOR_OVERLINE) :
        CommandStruct.new(INTERIOR_OVERLINE_OFF))

      self
    end

    def blink(enabled: true, rapid: false)
      @options[:other] << (
        if enabled
          rapid ?
            CommandStruct.new(INTERIOR_BLINK_RAPID) :
            CommandStruct.new(INTERIOR_BLINK)
        else
          CommandStruct.new(INTERIOR_BLINK_OFF)
        end
      )

      self
    end

    def invisible(enabled: true)
      @options[:other] << (enabled ?
        CommandStruct.new(INTERIOR_INVISIBLE) :
        CommandStruct.new(INTERIOR_INVISIBLE_OFF))

      self
    end

    def inverse(enabled: true)
      @options[:other] << (enabled ?
        CommandStruct.new(INTERIOR_INVERSE) :
        CommandStruct.new(INTERIOR_INVERSE_OFF))

      self
    end

    def strike_through(enabled: true)
      @options[:other] << (enabled ?
        CommandStruct.new(INTERIOR_STRIKE_THROUGH) :
        CommandStruct.new(INTERIOR_STRIKE_THROUGH_OFF))

      self
    end

    # @return self
    def fg_color(index: nil, name: nil)
      if index
        @options[:color] << CommandStruct.new(
          INTERIOR_COLOR_FG_EXTEND,
          INTERIOR_COLOR_BY_INDEX,
          index
        )
      elsif name
        parameter  = INTERIOR_COLOR_FG_BASE
        parameter += color_name2index(interior_type: __method__, name: name)
        @options[:color] << CommandStruct.new(parameter)
      end

      self
    end

    # @return self
    def bg_color(index: nil, name: nil)
      if index
        @options[:color] << CommandStruct.new(
          INTERIOR_COLOR_BG_EXTEND,
          INTERIOR_COLOR_BY_INDEX,
          index
        )
      elsif name
        parameter  = INTERIOR_COLOR_BG_BASE
        parameter += color_name2index(interior_type: __method__, name: name)
        @options[:color] << CommandStruct.new(parameter)
      end

      self
    end

    # @return self
    def colors_by_name(fg: nil, bg: nil, underline: nil)
      fg && fg_color(name: fg)
      bg && bg_color(name: bg)
      underline && underline_color(name: underline)

      self
    end

    # @return self
    def colors_by_index(fg: nil, bg: nil, underline: nil)
      fg && fg_color(name: fg)
      bg && bg_color(name: bg)
      underline && underline_color(index: underline)

      self
    end

    # @return self
    def underline_color(name: nil, index: nil)
      if index
        @options[:color] << CommandStruct.new(
          INTERIOR_COLOR_UNDERLINE_EXTEND,
          INTERIOR_COLOR_BY_INDEX,
          index
        )
      elsif name
        @options[:color] << CommandStruct.new(
          INTERIOR_COLOR_UNDERLINE_EXTEND,
          INTERIOR_COLOR_BY_INDEX,
          color_name2index(interior_type: __method__, name: name)
        )
      end

      self
    end

    private

    # @param [Symbol] interior_type
    # @param [Symbol] name
    # @return [Integer]
    def color_name2index(interior_type:, name:)
      color_index = @@named_colors[name]
      return color_index unless name.to_s.include?('bright')
      return color_index unless interior_type.to_s =~ /[fb]g_color/

      color_index - @@named_colors.length / 2 + INTERIOR_COLOR_BRIGHT_SLIDE
    end
  end
end
