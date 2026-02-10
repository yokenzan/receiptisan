# frozen_string_literal: true

require 'month'
require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Parser::MasterHandler do
  let(:master_loader) { instance_double(Receiptisan::Model::ReceiptComputer::Master::Loader) }
  let(:handler)       { described_class.new(master_loader) }

  describe '#prepare' do
    context '対応するバージョンが存在する診療年月の場合' do
      let(:loaded_master) { instance_double(Receiptisan::Model::ReceiptComputer::Master) }

      before do
        allow(master_loader).to receive(:load).and_return(loaded_master)
      end

      specify '例外を投げないこと' do
        expect { handler.prepare(Month.new(2024, 6)) }.not_to raise_error
      end

      specify '同一バージョンのマスタは再ロードしないこと' do
        handler.prepare(Month.new(2024, 6))
        handler.prepare(Month.new(2024, 7))

        expect(master_loader).to have_received(:load).once
      end
    end

    context '対応するバージョンが存在しない診療年月の場合' do
      specify '明確なエラーメッセージで例外を投げること' do
        expect { handler.prepare(Month.new(2017, 3)) }.to raise_error(RuntimeError, /対応するマスターバージョンが見つかりません/)
      end

      specify 'エラーメッセージに診療年月が含まれること' do
        expect { handler.prepare(Month.new(2017, 3)) }.to raise_error(RuntimeError, /2017/)
      end
    end
  end
end
