require 'spec_helper'
require_relative '../fixtures/test'

describe Typero do
  describe 'Class access' do
    it 'lists loaded classes' do
      expect(Typero.list).to eq(['Test', 'TestFoo', 'TestBar'])
    end

    it 'lists loaded model classes' do
      expect(Typero.list(:model)).to eq(['TestFoo', 'TestBar'])
    end
  end
end
