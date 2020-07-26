require 'spec_helper'
require_relative '../fixtures/all'

describe Typero::Schema do
  before(:all) do
    @test  = Test.new
    @rules = TestSchema
  end

  it 'should render string' do
    schema = Typero.schema do
      data downcase: true
    end

    data  = { data: '  aBc  ' }
    errors = schema.validate data
    expect(data[:data]).to eq 'abc'
  end

  it 'speed should be Float' do
    @test.speed = '10'
    errors = @rules.validate(@test)
    expect(@test.speed.class).to eq(Float)
    expect(@test.speed).to eq(10.0)
  end

  it 'email to be valid' do
    @test.email = 'dux@dux.net'
    @rules.valid? @test
    expect(@test.email).to eq('dux@dux.net')
    expect(@test[:email]).to eq('dux@dux.net')
  end

  it 'email to fail' do
    @test.email = 'duxdux.net'
    errors = @rules.validate @test
    expect(errors[:email].include?('@')).to be_truthy
  end

  it 'shout get right boolean values' do
    schema = Typero.schema do
      foo  true
      bar  false
      baz  :boolean
    end

    data = {}
    errors = schema.validate data

    expect(errors[:foo]).to be_nil
    expect(errors[:bar]).to be_nil
    expect(errors[:baz]).to include('required')

    data = { foo: 'off', bar: '1', baz: 'false' }
    errors = schema.validate data
    expect(data).to eq(foo: false, bar: true, baz: false)
    expect(errors.keys.length).to eq(0)
  end

  it 'url shuld fail then pass' do
    schema = Typero.schema do
      url  :url
    end

    errors = schema.validate url: 'slashdot.org'
    expect(errors[:url]).to include('not starting')

    errors = schema.validate url: 'https://slashdot.org'
    expect(errors[:url]).to be_nil
  end

  it 'should convert empty strings to nil' do
    schema = Typero.schema do
      foo
    end
    h = { foo: '', bar: '' }
    schema.validate h
    expect(h[:foo]).to eq(nil)
    expect(h[:bar]).to eq('')
  end
end