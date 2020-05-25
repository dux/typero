require 'spec_helper'
require_relative '../fixtures/all'

Typero(:cache) do
  name
end

FuncSchema = Typero do
  name
end

describe Typero do
  describe 'Func access' do
    it 'can create schema' do
      expect(FuncSchema.rules[:name][:type]).to eq('string')
    end

    it 'it can set and access the schema' do
      expect(Typero(:cache).rules[:name][:type]).to eq('string')
    end

    it 'it can access the class stype schema' do
      expect(Typero(:func).rules[:name][:type]).to eq('string')
    end
  end
end
