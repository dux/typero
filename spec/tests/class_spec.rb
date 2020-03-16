require 'spec_helper'
require_relative '../fixtures/all'

describe Typero do
  describe 'Class access' do
    it 'lists loaded classes' do
      expect(Typero.list).to eq(['Test', 'TestFoo', 'TestBar'])
    end

    it 'lists loaded model classes' do
      expect(Typero.list(:model)).to eq(['TestFoo', 'TestBar'])
    end
  end

  describe 'Schema exists' do
    it 'returns schema when schema exists' do
      expect(Typero.defined?(:test)).to eq(true)
    end

    it 'returns nil when does not exists' do
      expect(Typero.defined?(:test_naat)).to eq(false)
    end
  end
end
