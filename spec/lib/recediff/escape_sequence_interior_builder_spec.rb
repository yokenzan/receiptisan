# frozen_string_literal: true

require 'recediff'

RSpec.describe Recediff::EscapeSequenceInteriorBuilder do
  let(:builder) { Recediff::EscapeSequenceInteriorBuilder.new }
  describe 'can apply various interiors' do
    it 'should be bold' do
      # @type [Recediff::EscapeSequenceInteriorBuilder] builder
      expect(builder.bold.build).to eq "\e[1m"
    end

    it 'should be dim' do
      expect(builder.dim.build).to eq "\e[2m"
    end

    it 'should be italic' do
      # @type [Recediff::EscapeSequenceInteriorBuilder] builder
      expect(builder.italic.build).to eq "\e[3m"
    end

    it 'should be underlined with single line' do
      # @type [Recediff::EscapeSequenceInteriorBuilder] builder
      expect(builder.underline(style: :single).build).to eq "\e[4:1m"
    end

    it 'should be underlined with single line when called without arguments' do
      # @type [Recediff::EscapeSequenceInteriorBuilder] builder
      expect(builder.underline.build).to eq builder.underline(style: :single).build
    end

    it 'should be underlined with doubled lines' do
      # @type [Recediff::EscapeSequenceInteriorBuilder] builder
      expect(builder.underline(style: :double).build).to eq "\e[4:2m"
    end
  end

  describe 'interiors can be applied at same time' do
    it 'should be both bold and italic' do
      # @type [Recediff::EscapeSequenceInteriorBuilder] builder
      expect(builder.bold.italic.build).to eq "\e[1;3m"
    end
  end

  describe 'state preservation' do
    it 'should be cleared after build interior sequence' do
      expect(builder.bold.italic.build).to eq "\e[1;3m"
      expect(builder.build).to eq ''
    end

    it 'should be preserved after build interior sequence' do
      expect(builder.bold.italic.build(preserve_state: true)).to eq "\e[1;3m"
      expect(builder.build).to eq "\e[1;3m"
    end
  end
end
