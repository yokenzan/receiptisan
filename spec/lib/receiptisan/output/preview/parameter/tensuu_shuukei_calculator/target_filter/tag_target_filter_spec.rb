# frozen_string_literal: true

require 'receiptisan'

RSpec.describe Receiptisan::Output::Preview::Parameter::TensuuShuukeiCalculator::TargetFilter::TagTargetFilter do
  before do
    stub_const('Tag', Receiptisan::Model::ReceiptComputer::Tag::Tag)
    stub_const('Cost', Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::Cost)
    stub_const('SanteiUnit', Receiptisan::Model::ReceiptComputer::DigitalizedReceipt::Receipt::Tekiyou::SanteiUnit)
    stub_const('ShinryouKoui', Receiptisan::Model::ReceiptComputer::Master::Treatment::ShinryouKoui)
  end

  # cost double を生成するヘルパー
  # @param code_value [Symbol] レセ電コード
  def make_cost(code_value)
    code = instance_double(ShinryouKoui::Code, value: code_value)
    resource = instance_double(ShinryouKoui, code: code)
    instance_double(Cost, resource: resource)
  end

  # santei_unit double を生成するヘルパー
  # @param code_values [Array<Symbol>] 含まれる cost のレセ電コード群
  def make_santei_unit(*code_values)
    costs = code_values.map { | cv | make_cost(cv) }
    instance_double(SanteiUnit, each_cost: costs)
  end

  describe '#target?' do
    context 'forbidden_code が空の場合' do
      let(:tag) do
        Tag.new(
          key:                 :test_tag,
          label:               'テスト',
          shinryou_shikibetsu: [],
          code:                %i[111000110 112345678],
          forbidden_code:      []
        )
      end
      let(:filter) { described_class.new(tag) }

      context '必須コードを含む算定単位' do
        it 'true を返すこと' do
          santei_unit = make_santei_unit(:'111000110')
          expect(filter.target?(santei_unit)).to be true
        end
      end

      context '必須コードを含まない算定単位' do
        it 'false を返すこと' do
          santei_unit = make_santei_unit(:'999999999')
          expect(filter.target?(santei_unit)).to be false
        end
      end

      context '複数の cost のうち1つが必須コードを含む算定単位' do
        it 'true を返すこと' do
          santei_unit = make_santei_unit(:'999999999', :'111000110')
          expect(filter.target?(santei_unit)).to be true
        end
      end
    end

    context 'forbidden_code が設定されている場合' do
      let(:tag) do
        Tag.new(
          key:                 :test_tag,
          label:               'テスト',
          shinryou_shikibetsu: [],
          code:                %i[111000110 112345678],
          forbidden_code:      %i[900000001 900000002]
        )
      end
      let(:filter) { described_class.new(tag) }

      context '必須コードを含み、禁止コードを含まない算定単位' do
        it 'true を返すこと' do
          santei_unit = make_santei_unit(:'111000110')
          expect(filter.target?(santei_unit)).to be true
        end
      end

      context '必須コードを含み、禁止コードも含む算定単位' do
        it 'false を返すこと' do
          santei_unit = make_santei_unit(:'111000110', :'900000001')
          expect(filter.target?(santei_unit)).to be false
        end
      end

      context '必須コードと禁止コードの両方を含む（複数 cost）算定単位' do
        it 'false を返すこと' do
          santei_unit = make_santei_unit(:'111000110', :'999999999', :'900000002')
          expect(filter.target?(santei_unit)).to be false
        end
      end

      context '必須コードを含まず、禁止コードを含む算定単位' do
        it 'false を返すこと' do
          santei_unit = make_santei_unit(:'900000001')
          expect(filter.target?(santei_unit)).to be false
        end
      end

      context '必須コードも禁止コードも含まない算定単位' do
        it 'false を返すこと' do
          santei_unit = make_santei_unit(:'999999999')
          expect(filter.target?(santei_unit)).to be false
        end
      end
    end
  end
end
