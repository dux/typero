require 'spec_helper'
# require_relative '../fixtures/all'

Typero.schema(:cache) do
  name
end

FuncSchema = Typero.schema do
  name

  integer! do
    num
    labels Set[:label]
  end

  false! do
    is_active
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
      expect(FuncSchema.rules[:name][:type]).to eq(:string)
    end

    it 'can defined nested schema' do
      s = FuncSchema.rules
      expect(s[:num][:type]).to eq(:integer)
      expect(s[:num][:required]).to eq(true)
      expect(s[:labels][:required]).to eq(true)
      expect(s[:labels][:array]).to eq(true)
      expect(s[:labels][:type]).to eq(:integer)
      expect(s[:is_active][:type]).to eq(:boolean)
    end
  end
end
