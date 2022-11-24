# frozen_string_literal: true

require_relative 'loader/loader_trait'
require_relative 'loader/shinryou_koui_loader'
require_relative 'loader/iyakuhin_loader'
require_relative 'loader/tokutei_kizai_loader'
require_relative 'loader/comment_loader'
require_relative 'loader/shoubyoumei_loader'
require_relative 'loader/shuushokugo_loader'

module Receiptisan
  module Model
    module ReceiptComputer
      class Master
        class Loader
          # @param resource_resolver [ResourceResolver]
          def initialize(resource_resolver)
            @resource_resolver    = resource_resolver
            @shinryou_koui_loader = ShinryouKouiLoader.new
            @iyakuhin_loader      = IyakuhinLoader.new
            @tokutei_kizai_loader = TokuteiKizaiLoader.new
            @comment_loader       = CommentLoader.new
            @shoubyoumei_loader   = ShoubyoumeiLoader.new
            @shuushokugo_loader   = ShuushokugoLoader.new
          end

          # @param version [Version]
          # @return [Master]
          def load(version)
            csv_paths = @resource_resolver.detect_csv_files(version)
            load_from_version_and_csv(version, **csv_paths)
          end

          # @param version [Version]
          # @param shinryou_koui_csv_path [String]
          # @param iyakuhin_csv_path [String]
          # @param tokutei_kizai_csv_path [String]
          # @param comment_csv_path [String]
          # @param shoubyoumei_csv_path [String]
          # @param shuushokugo_csv_path [String]
          # @return [Master]
          def load_from_version_and_csv(
            version,
            shinryou_koui_csv_path:,
            iyakuhin_csv_path:,
            tokutei_kizai_csv_path:,
            comment_csv_path:,
            shoubyoumei_csv_path:,
            shuushokugo_csv_path:
          )
            Master.new(
              shinryou_koui: @shinryou_koui_loader.load(version, shinryou_koui_csv_path),
              iyakuhin:      @iyakuhin_loader.load(iyakuhin_csv_path),
              tokutei_kizai: @tokutei_kizai_loader.load(tokutei_kizai_csv_path),
              comment:       @comment_loader.load(comment_csv_path),
              shoubyoumei:   @shoubyoumei_loader.load(shoubyoumei_csv_path),
              shuushokugo:   @shuushokugo_loader.load(shuushokugo_csv_path)
            )
          end
        end
      end
    end
  end
end
