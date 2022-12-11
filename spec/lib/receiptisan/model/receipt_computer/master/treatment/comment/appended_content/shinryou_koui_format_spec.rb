# frozen_string_literal: true

require 'receiptisan'
require_relative 'appended_content_interface'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::Treatment::Comment::AppendedContent::ShinryouKouiFormat do
  before do
    stub_const('Master',    Receiptisan::Model::ReceiptComputer::Master)
    stub_const('Treatment', Receiptisan::Model::ReceiptComputer::Master::Treatment)
  end

  let(:master_shinryou_koui) do
    Treatment::ShinryouKoui.new(
      code:       Treatment::ShinryouKoui::Code.of('170000410'),
      name:       '単純撮影（イ）の写真診断',
      name_kana:  'タンジュンサツエイノシャシンシンダン',
      unit:       Master::Unit.find_by_code(6), # 枚
      point_type: Treatment::ShinryouKoui::PointType.find_by_code(:'3'), # 点数(プラス)
      point:      85,
      full_name:  '単純撮影（頭部、胸部、腹部又は脊椎）の写真診断'
    )
  end
  let(:target) { described_class.new(master_shinryou_koui) }

  describe 'behave as appended content' do
    it_behaves_like 'appended_content_interface'
  end

  describe '#to_s' do
    specify 'master_shinryou_koui#nameを返す' do
      expect(target.to_s).to eq master_shinryou_koui.name
    end
  end
end
