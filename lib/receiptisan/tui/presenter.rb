# frozen_string_literal: true

require 'date'

module Receiptisan
  module Tui
    # ドメインモデルの Receipt を TUI 表示用データに変換する
    class Presenter # rubocop:disable Metrics/ClassLength
      using Receiptisan::Util::WarekiExtension

      Receipt = Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt

      # レセプト一覧表示用データ
      ListItem = Struct.new(:label, keyword_init: true)

      # ヘッダー表示用データ
      HeaderData = Struct.new(:patient_line, :type_line, :tokki_line, :nyuuin_line, keyword_init: true)

      # 摘要行
      TekiyouLine = Struct.new(:text, :resource_type, :indent, keyword_init: true)

      # 会計行
      KaikeiLine = Struct.new(:label, :value, keyword_init: true)

      # @param receipts [Array<Receipt>]
      # @return [Array<ListItem>]
      def list_items(receipts)
        receipts.each_with_index.map do | receipt, index |
          no      = format('No.%04d', index + 1)
          ym      = receipt.shinryou_ym.to_wareki
          nyuugai = receipt.nyuuin? ? '入院' : '外来'
          name    = receipt.patient.name || ''

          ListItem.new(label: "#{no} #{ym} #{nyuugai} #{name}")
        end
      end

      # @param receipt [Receipt]
      # @return [HeaderData]
      def header(receipt)
        HeaderData.new(
          patient_line: build_patient_line(receipt.patient),
          type_line:    build_type_line(receipt),
          tokki_line:   build_tokki_line(receipt),
          nyuuin_line:  receipt.nyuuin_date ? "入院日: #{receipt.nyuuin_date.to_wareki}" : nil
        )
      end

      # @param receipt [Receipt]
      # @return [Array<TekiyouLine>]
      def tekiyou(receipt)
        lines = []

        receipt.each do | shinryou_shikibetsu_code, ichiren_units |
          shikibetsu = Receipt::ShinryouShikibetsu.find_by_code(shinryou_shikibetsu_code)
          shikibetsu_name = shikibetsu ? "#{shikibetsu.code} #{shikibetsu.name}" : shinryou_shikibetsu_code.to_s

          lines << TekiyouLine.new(text: "--- #{shikibetsu_name} ---", resource_type: :header, indent: 0)
          ichiren_units.each { | ichiren_unit | build_ichiren_lines(ichiren_unit, lines) }
          lines << TekiyouLine.new(text: '', resource_type: :spacer, indent: 0)
        end

        lines
      end

      # @param receipt [Receipt]
      # @return [Array<KaikeiLine>]
      def kaikei(receipt)
        lines = []
        build_iryou_hoken_lines(receipt.iryou_hoken, lines)
        build_kouhi_lines(receipt.kouhi_futan_iryous, lines)
        build_shoubyoumei_lines(receipt.shoubyoumeis, lines)
        build_tokki_jikou_lines(receipt.tokki_jikous, lines)
        lines
      end

      private

      # @return [String]
      def build_patient_line(patient)
        [
          "患者: [#{patient.id}]",
          patient.name,
          patient.sex&.short_name,
          patient.birth_date&.to_wareki,
        ].compact.join(' ')
      end

      # @return [String]
      def build_type_line(receipt)
        type = receipt.type
        [
          receipt.nyuuin? ? '入院' : '外来',
          type.patient_age_type&.name,
          type.main_hoken_type&.name,
          type.hoken_multiple_type&.name,
        ].compact.join(' ')
      end

      # @return [String, nil]
      def build_tokki_line(receipt)
        names = receipt.tokki_jikous.values.map(&:name)
        names.empty? ? nil : "特記: #{names.join(' ')}"
      end

      # @param hoken [Receipt::IryouHoken, nil]
      # @param lines [Array<KaikeiLine>]
      def build_iryou_hoken_lines(hoken, lines)
        return unless hoken

        lines << KaikeiLine.new(label: '== 医療保険 ==', value: '')
        lines << KaikeiLine.new(label: '保険者番号', value: hoken.hokenja_bangou.to_s)
        lines << KaikeiLine.new(label: '記号・番号', value: [hoken.kigou, hoken.bangou].compact.join('・'))
        lines << KaikeiLine.new(label: '給付割合', value: hoken.kyuufu_wariai ? "#{hoken.kyuufu_wariai}割" : '')
        append_nissuu_kyuufu_lines(hoken, lines)
        lines << KaikeiLine.new(label: '', value: '')
      end

      # @param kouhi_hash [Hash]
      # @param lines [Array<KaikeiLine>]
      def build_kouhi_lines(kouhi_hash, lines)
        kouhi_hash.each do | order, kouhi |
          lines << KaikeiLine.new(label: "== 公費 (#{order.name}) ==", value: '')
          lines << KaikeiLine.new(label: '負担者番号', value: kouhi.futansha_bangou.to_s)
          lines << KaikeiLine.new(label: '受給者番号', value: kouhi.jukyuusha_bangou.to_s)
          append_nissuu_kyuufu_lines(kouhi, lines)
          lines << KaikeiLine.new(label: '', value: '')
        end
      end

      # @param hoken_or_kouhi [Object]
      # @param lines [Array<KaikeiLine>]
      def append_nissuu_kyuufu_lines(hoken_or_kouhi, lines)
        lines << KaikeiLine.new(label: '合計点数', value: format_number(hoken_or_kouhi.goukei_tensuu))
        lines << KaikeiLine.new(label: '実日数', value: format_number(hoken_or_kouhi.shinryou_jitsunissuu))
        lines << KaikeiLine.new(label: '一部負担金', value: format_number(hoken_or_kouhi.ichibu_futankin))
        return unless hoken_or_kouhi.shokuji_seikatsu_ryouyou_kaisuu

        lines << KaikeiLine.new(label: '食事回数', value: format_number(hoken_or_kouhi.shokuji_seikatsu_ryouyou_kaisuu))
        lines << KaikeiLine.new(
          label: '食事合計額',
          value: format_number(hoken_or_kouhi.shokuji_seikatsu_ryouyou_goukei_kingaku)
        )
      end

      # @param shoubyoumeis [Array]
      # @param lines [Array<KaikeiLine>]
      def build_shoubyoumei_lines(shoubyoumeis, lines)
        return if shoubyoumeis.empty?

        lines << KaikeiLine.new(label: '== 傷病名 ==', value: '')
        shoubyoumeis.each { | s | lines << KaikeiLine.new(label: s.name, value: '') }
        lines << KaikeiLine.new(label: '', value: '')
      end

      # @param tokki_jikous [Hash]
      # @param lines [Array<KaikeiLine>]
      def build_tokki_jikou_lines(tokki_jikous, lines)
        return if tokki_jikous.empty?

        lines << KaikeiLine.new(label: '== 特記事項 ==', value: '')
        tokki_jikous.each_value { | t | lines << KaikeiLine.new(label: "#{t.code} #{t.name}", value: '') }
      end

      # @param ichiren_unit [Receipt::Tekiyou::IchirenUnit]
      # @param lines [Array<TekiyouLine>]
      def build_ichiren_lines(ichiren_unit, lines)
        ichiren_unit.each do | santei_unit |
          build_santei_unit_lines(santei_unit, lines)
        end
      end

      # @param santei_unit [Receipt::Tekiyou::SanteiUnit]
      # @param lines [Array<TekiyouLine>]
      def build_santei_unit_lines(santei_unit, lines)
        santei_unit.each { | item | build_tekiyou_item_line(item, lines) }

        return unless santei_unit.tensuu

        tensuu_text = "#{santei_unit.tensuu}点"
        tensuu_text += " x #{santei_unit.kaisuu}回" if santei_unit.kaisuu && santei_unit.kaisuu > 1
        lines << TekiyouLine.new(text: "    #{tensuu_text}", resource_type: :tensuu, indent: 3)
      end

      # @param tekiyou_item [Receipt::Tekiyou::Cost, Receipt::Tekiyou::Comment]
      # @param lines [Array<TekiyouLine>]
      def build_tekiyou_item_line(tekiyou_item, lines)
        if tekiyou_item.comment?
          lines << TekiyouLine.new(text: tekiyou_item.format, resource_type: :comment, indent: 2)
        else
          build_cost_line(tekiyou_item, lines)
        end
      end

      # @param cost [Receipt::Tekiyou::Cost]
      # @param lines [Array<TekiyouLine>]
      def build_cost_line(cost, lines)
        resource = cost.resource
        lines << TekiyouLine.new(text: build_cost_text(resource), resource_type: resource.type, indent: 1)

        cost.each_comment do | comment |
          lines << TekiyouLine.new(text: "  #{comment.format}", resource_type: :comment, indent: 2)
        end
      end

      # @param resource [Object]
      # @return [String]
      def build_cost_text(resource)
        parts = [resource.name]
        if resource.shiyouryou
          unit_name = resource.unit&.name || ''
          parts << " #{resource.shiyouryou}#{unit_name}"
        end
        parts.join
      end

      # @param value [Integer, nil]
      # @return [String]
      def format_number(value)
        return '' if value.nil?

        value.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
      end
    end
  end
end
