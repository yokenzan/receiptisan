# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations

require 'receiptisan'

RSpec.describe Receiptisan::Model::ReceiptComputer::Master::CachePolicy do
  describe 'default values' do
    subject(:policy) { described_class.new }

    it 'cache missでは自動書き込みしない' do
      expect(policy.write_on_cache_miss?).to be(false)
    end

    it 'cache miss時に警告を出す' do
      expect(policy.warn_on_cache_miss?).to be(true)
    end

    it '生成コマンドを保持する' do
      expect(policy.generate_cache_command).to eq('rake master:generate_cache')
    end
  end

  describe 'custom values' do
    subject(:policy) do
      described_class.new(
        write_on_cache_miss:    true,
        warn_on_cache_miss:     false,
        generate_cache_command: 'bundle exec rake master:generate_cache VERSION=2024'
      )
    end

    it '指定値を反映する' do
      expect(policy.write_on_cache_miss?).to be(true)
      expect(policy.warn_on_cache_miss?).to be(false)
      expect(policy.generate_cache_command).to eq('bundle exec rake master:generate_cache VERSION=2024')
    end
  end
end

# rubocop:enable RSpec/MultipleExpectations
