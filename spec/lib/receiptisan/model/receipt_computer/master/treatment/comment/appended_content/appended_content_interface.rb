# frozen_string_literal: true

RSpec.shared_examples 'appended_content_interface' do
  describe '#to_s' do
    specify '文字列化できること' do
      expect(target).to respond_to(:to_s)
    end
  end
end
