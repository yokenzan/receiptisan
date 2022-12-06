# frozen_string_literal: true

module Receiptisan
  module Output
    module Preview
      module LineBuilder
        # 傷病名欄行の生成
        class ShoubyouLineBuilder
          COMMA = '，'

          def initialize(max_line_length: 32, max_line_count: 5)
            @max_line_length = max_line_length
            @max_line_count  = max_line_count
          end

          def build(shoubyoumei_groups)
            @current_line_count = 0
            @result             = Result.new(
              lines:    [],
              has_more: false,
              target:   [],
              rest:     []
            )

            shoubyoumei_groups.each_with_index do | group, group_index |
              built = build_shoubyoumei_group(group, group_index)

              if built.nil?
                @result.rest     = shoubyoumei_groups[group_index..]
                @result.has_more = true
                break
              end

              @result.target << group
              @result.lines.concat(built)
            end

            @result
          end

          private

          def build_shoubyoumei_group(group, group_index)
            names_for_lines = build_name_lines(group, group_index)

            @current_line_count += names_for_lines.length

            return if @current_line_count > @max_line_count

            names_for_lines.map.with_index do | names, index |
              number = generate_rounded_number_mark(group_index)

              ShoubyouLine.new(
                name:       names,
                start_date: index.zero? ? number + group.start_date.wareki.text : nil,
                tenki:      index.zero? ? number + group.tenki.name             : nil
              )
            end
          end

          def build_name_lines(group, group_index)
            group.shoubyoumeis
              .map { | shoubyou | to_zenkaku shoubyou.full_text }
              .each_with_object([generate_rounded_number_mark(group_index)]) do | name, names_for_lines |
                if [names_for_lines.last, name].join(COMMA).length > @max_line_length
                  names_for_lines.last << COMMA
                  names_for_lines << '' + '　'
                end
                # names_for_lines.last.length == 1 は 行の中身が「①」など番号だけの状態かを判定している
                names_for_lines.last.concat(names_for_lines.last.length == 1 ? '' : COMMA, name)
              end
          end

          # マル付数字の文字を生成する
          def generate_rounded_number_mark(index)
            (0x2460 + index).chr('UTF-8') # ①
          end

          def to_zenkaku(number)
            number.to_s.tr('−() A-Za-z0-9.', '―（）　Ａ-Ｚａ-ｚ０-９．')
          end

          attr_writer :max_line_length, :max_line_count, :delimitor

          ShoubyouLine = Struct.new(:name, :start_date, :tenki, keyword_init: true)
          Result       = Struct.new(:target, :lines, :has_more, :rest, keyword_init: true)
        end
      end
    end
  end
end
