require 'spec_helper'
require_relative '../fixtures/all'

Typero.schema(:cache) do
  name
end

FuncSchema = Typero.schema do
  name

  integer! do
    num
  end
end

describe Typero do
  describe 'Func access' do
    it 'can create schema' do
      expect(FuncSchema.rules[:name][:type]).to eq(:string)
    end

    it 'it can set and access the schema' do
      expect(Typero.schema(:cache).rules[:name][:type]).to eq(:string)
    end

    it 'it can access the class stype schema' do
      expect(Typero.schema(:func).rules[:name][:type]).to eq(:string)
    end

    it 'can defined nested schema' do
      expect(FuncSchema.rules[:num][:type]).to eq(:integer)
      expect(FuncSchema.rules[:num][:required]).to eq(true)
    end
  end
end
