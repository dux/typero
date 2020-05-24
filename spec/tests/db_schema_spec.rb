require_relative '../spec_helper'
require_relative '../fixtures/all'

describe Typero do
  before(:all) do
    @rules = TestSchema
  end

  describe 'DB schema access' do
    it 'gets valid schema' do
      schema = @rules.db_schema
      expect(schema[0]).to eq([:string, :name, { default: nil, limit: 255}])
      expect(schema[1]).to eq([:float, :speed, {}])
      expect(schema[2]).to eq([:string, :email, { limit: 120, null: false }])
      expect(schema[3]).to eq([:string, :email_nil, { limit: 120 }])
      expect(schema[4]).to eq([:string, :emails, { array: true, limit: 120}])
      # expect(schema[5]).to eq([:string, :tags, { array: true, limit: 30}])
      # expect(schema[6]).to eq([:string, :eyes, { default: 'blue', limit: 255}])
      expect(schema[7]).to eq([:integer, :age, { default: nil, null: false}])
      expect(schema.last).to eq([:timestamps])
    end
  end
end