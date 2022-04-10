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
    INTERIOR_ITALIC                 = 3
    INTERIOR_UNDERLINE              = 4
    INTERIOR_BLINK                  = 5
    INTERIOR_BLINK_RAPID            = 6
    INTERIOR_NORMAL                 = 22
    INTERIOR_ITALIC_OFF             = 23
    INTERIOR_BLINK_OFF              = 25
    INTERIOR_COLOR_FG_BASE          = 30
    INTERIOR_COLOR_FG_EXTEND        = 38
    INTERIOR_COLOR_BG_BASE          = 40
    INTERIOR_COLOR_BG_EXTEND        = 48
    INTERIOR_COLOR_UNDERLINE_EXTEND = 58

    INTERIOR_COLOR_BY_RGB           = 2
    INTERIOR_COLOR_BY_INDEX         = 5

    @@underline_styles = {
      disabled: 0,
      single:   1,
      double:   2,
      curly:    3,
      dotted:   4,
      dashed:   5,
    }.freeze

    @@named_colors = {
      black:   0,
      red:     1,
      green:   2,
      yellow:  3,
      blue:    4,
      magenta: 5,
      cyan:    6,
      white:   7,
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
    def bold(flag: true)
      @options[:brightness] << (flag ?
        CommandStruct.new(INTERIOR_BOLD) :
        CommandStruct.new(INTERIOR_NORMAL))

      self
    end

    def dim(flag: true)
      @options[:brightness] << (flag ?
        CommandStruct.new(INTERIOR_DIM) :
        CommandStruct.new(INTERIOR_NORMAL))

      self
    end

    # @return self
    def italic(flag: true)
      @options[:other] << (flag ?
        CommandStruct.new(INTERIOR_ITALIC) :
        CommandStruct.new(INTERIOR_ITALIC_OFF))

      self
    end

    # @return self
    def underline(flag: true, style: :single)
      command =  CommandStruct.new(INTERIOR_UNDERLINE)
      command << (flag ?
        @@underline_styles[style] :
        @@underline_styles[:disabled])

      @options[:underline] << command

      self
    end

    def blink(flag: true, rapid: false)
      @options[:other] << (
        if flag
          rapid ?
            CommandStruct.new(INTERIOR_BLINK_RAPID) :
            CommandStruct.new(INTERIOR_BLINK)
        else
          CommandStruct.new(INTERIOR_BLINK_OFF)
        end
      )

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
        parameter += @@named_colors[name]
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
        parameter += @@named_colors[name]
        @options[:color] << CommandStruct.new(parameter)
      end

      self
    end

    # @return self
    def colors_by_name(fg: nil, bg: nil)
      fg && fg_color(name: fg)
      bg && bg_color(name: bg)

      self
    end

    # @return self
    def colors_by_index(fg: nil, bg: nil)
      fg && fg_color(name: fg)
      bg && bg_color(name: bg)

      self
    end

    # @return self
    def underline_color(name:, index:)
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
          @@named_colors[:name]
        )
      end

      self
    end
  end
end
