require_relative '../spec_helper'

Typero.schema :user1 do
  name
  email :email
end

Typero.schema :api1 do
  foo
  user  model: :user1
end

describe Typero::ModelType do
  describe 'DB schema access' do
    let(:opts) {
      {
        foo: 123,
        bar: 456,
        user: {
          name: 'Dux',
          is_admin: true
        }
      }
    }

    it 'gets valid schema' do
      opts[:user][:email] = 'dux.net.hr'
      validated = Typero.schema(:api1).validate(opts)
      expect(validated[:user]).to include('missing')
    end

    it 'gets valid schema' do
      opts[:user][:email] = 'dux@net.hr'
      validated = Typero.schema(:api1).validate(opts)
      expect(validated.keys.length).to eq(0)
    end
  end
end