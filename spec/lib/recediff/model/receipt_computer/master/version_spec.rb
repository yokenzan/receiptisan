# frozen_string_literal: true

require 'month'
require 'recediff'

Version = Recediff::Model::ReceiptComputer::Master::Version

RSpec.describe Version do
  let!(:target) { Version.new(2022, Month.new(2022, 4), Month.new(2024, 3)) }

  describe '#year' do
    specify '点数表の版の初年を返すこと' do
      expect(target.year).to eq 2022
    end
  end

  describe '#term' do
    specify '版の期間をRangeで返すこと' do
      expect(target.term).to be_an_instance_of Range
    end

    specify '期間の起点は開始月であること' do
      expect(target.term.begin).to eq Month.new(2022, 4)
    end

    specify '期間の終点は終了月であること' do
      expect(target.term.end).to eq Month.new(2024, 3)
    end
  end

  describe '#include?' do
    context 'ある暦月が期間内の場合' do
      specify '暦月が期間の起点の場合、真を返す' do
        expect(target.include?(Month.new(2022, 4))).to be true
      end

      specify '暦月が期中の場合、真を返す' do
        expect(target.include?(Month.new(2022, 4))).to be true
      end

      specify '暦月が期間の終点の場合、真を返す' do
        expect(target.include?(Month.new(2024, 3))).to be true
      end
    end

    context 'ある暦月が期間外の場合' do
      specify '暦月が期間の起点よりも過去の場合、偽を返す' do
        expect(target.include?(Month.new(2022, 3))).to be false
      end

      specify '暦月が期間の終点よりも未来の場合、偽を返す' do
        expect(target.include?(Month.new(2024, 5))).to be false
      end
    end
  end

  describe '.resolve_by_ym' do
    context '2018年度点数表期間の起点よりも過去の暦月の場合' do
      specify 'nilを返す' do
        expect(described_class.resolve_by_ym(Month.new(2018, 3))).to be_nil
      end
    end

    context '2018年度点数表期間中の暦月の場合' do
      specify '起点月の場合、2018年度診療報酬点数表の版を返す' do
        expect(described_class.resolve_by_ym(Month.new(2018, 4))).to eq Version::V2018_H30
      end

      specify '終点月の場合、2018年度診療報酬点数表の版を返す' do
        expect(described_class.resolve_by_ym(Month.new(2019, 3))).to eq Version::V2018_H30
      end
    end

    context '2019年度点数表期間中の暦月の場合' do
      specify '起点月の場合、2020年度診療報酬点数表の版を返す' do
        expect(described_class.resolve_by_ym(Month.new(2019, 4))).to eq Version::V2019_R01
      end

      specify '終点月の場合、2020年度診療報酬点数表の版を返す' do
        expect(described_class.resolve_by_ym(Month.new(2020, 3))).to eq Version::V2019_R01
      end
    end

    context '2020年度点数表期間中の暦月の場合' do
      specify '起点月の場合、2022年度診療報酬点数表の版を返す' do
        expect(described_class.resolve_by_ym(Month.new(2020, 4))).to eq Version::V2020_R02
      end

      specify '終点月の場合、2022年度診療報酬点数表の版を返す' do
        expect(described_class.resolve_by_ym(Month.new(2022, 3))).to eq Version::V2020_R02
      end
    end

    context '2022年度点数表期間中の暦月の場合' do
      specify '起点月の場合、2022年度診療報酬点数表の版を返す' do
        expect(described_class.resolve_by_ym(Month.new(2022, 4))).to eq Version::V2022_R04
      end

      specify '終点月の場合、2022年度診療報酬点数表の版を返す' do
        expect(described_class.resolve_by_ym(Month.new(2024, 3))).to eq Version::V2022_R04
      end
    end

    context '2022年度点数表期間の終点よりも未来の暦月の場合' do
      specify 'nilを返す' do
        expect(described_class.resolve_by_ym(Month.new(2024, 4))).to be_nil
      end
    end
  end
end
