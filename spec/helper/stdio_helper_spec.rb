# frozen_string_literal: true

RSpec.describe StdioHelper, type: :helper do
  describe 'helpers must run collectly' do
    it '$stdout is STDIO or StringIO' do
      expect($stdout).to be STDOUT # rubocop:disable Style/GlobalStdStream

      toward_stringio do | stdout |
        expect(stdout).to be_instance_of StringIO
      end

      expect($stdout).to be STDOUT # rubocop:disable Style/GlobalStdStream
    end
  end
end
