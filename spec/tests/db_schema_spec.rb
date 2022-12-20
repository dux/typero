require_relative '../spec_helper'
require_relative '../fixtures/all'

describe Typero do
  before(:all) do
    @rules = TestSchema
  end

  describe 'DB schema access' do
    it 'gets valid schema' do
      schema = @rules.db_schema
      expect(schema[0]).to eq([:name, :string, { limit: 255}])
      expect(schema[1]).to eq([:speed, :float, {}])
      expect(schema[2]).to eq([:email, :string, { limit: 120, null: false }])
      expect(schema[3]).to eq([:email_nil, :string, { limit: 120 }])
      expect(schema[4]).to eq([:emails, :string, { array: true, limit: 120}])
      expect(schema[5]).to eq([:tags, :string, { array: true, limit: 30}])
      expect(schema[6]).to eq([:eyes, :string, { default: 'blue', limit: 255, null: false}])
      expect(schema[7]).to eq([:age, :integer, { null: false}])
      expect(schema.last).to eq([:db_rule!, :timestamps])
    end
  end
end
