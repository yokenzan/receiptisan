# frozen_string_literal: true

RSpec.shared_examples 'coded_item_with_short_name_examples' do | target, target_name, code, code_type, name, short_name |
  describe '#code' do
    specify "#{code_type}を返す" do
      expect(target.code).to be_an_instance_of code_type
    end

    specify "#{target_name}は#{code}を返す" do
      expect(target.code).to eq code
    end
  end

  describe '#name' do
    specify '文字列を返す' do
      expect(target.name).to be_an_instance_of String
    end

    specify "#{target_name}は '#{name}' を返す" do
      expect(target.name).to eq name
    end
  end

  describe '#short_name' do
    specify '文字列を返す' do
      expect(target.name).to be_an_instance_of String
    end

    specify "#{target_name}は '#{short_name}' を返す" do
      expect(target.short_name).to eq short_name
    end
  end
end
