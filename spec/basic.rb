require_relative '../lib/typero'
require 'active_support/core_ext/string' unless respond_to?(:capitalize)

class Test
  include Typero::Hash
  include Typero::Instance

  attribute :name
  attribute :speed, type:Float, min:10, max:200
  attribute :email, :email, req: true
  attribute :email_nil, :email
  attribute :age, Integer, nil:false
  attribute :eyes, default:'blue'
  attribute :maxage, :default=>lambda { |o| o.age * 5 }
  attribute :emails, Array[:email]
  attribute :tags, Array[:label]
end

class Test2
  include Typero::Instance

  attribute :name
end


describe Typero do
  before(:all) do
    @test  = Test.new
    @test2 = Test2.new
  end

  describe 'Hash access' do
    it 'speed should be Float' do
      @test.speed = '10'
      expect(@test.speed.class).to eq(Float)
      expect(@test.speed).to eq(10.0)
    end

    it 'speed min and max should be respected' do
      expect{ @test.speed = 5 }.to raise_error(TypeError)
      expect{ @test.speed = 555 }.to raise_error(TypeError)
    end

    it 'name should be string' do
      @test.name = :dino
      expect(@test.name).to eq('dino')
    end

    it 'name should allow null name' do
      @test.name = ''
      expect(@test.name).to eq(nil)
    end

    it 'email to be valid' do
      @test.email = 'dux@dux.net'
      expect(@test.email).to eq('dux@dux.net')
      expect(@test[:email]).to eq('dux@dux.net')
    end

    it 'email to fail' do
      expect{ @test.email = 'duxdux.net' }.to raise_error(TypeError)
    end

    it 'email in array to fail' do
       expect{ @test.emails = ['dux@dux.net','duxdux.net'] }.to raise_error(TypeError)
    end

    it 'label in array to fail' do
       expect{ @test.tags = ['foo@bar','baz'] }.to raise_error(TypeError)
    end

    it 'email in array to pass' do
       @test.emails = ['dux@dux.net','dux2@dux.net']
       expect(@test.emails).to eq(['dux@dux.net','dux2@dux.net'])
    end

    it 'label in array to pass' do
       @test.tags = ['foo','bar']
       expect(@test.tags).to eq(['foo','bar'])
    end

    it 'should not allow email nil' do
      expect{ @test.email = nil }.to raise_error(TypeError)
    end

    it 'should allow email nil' do
      @test.email_nil = nil
      expect(@test.email_nil).to eq(nil)
    end

    it 'age to be 20 and maxage to be 100' do
      @test.age = '20'
      expect(@test.age).to eq(20)
      expect(@test.maxage).to eq(100)
    end

    it 'expect eyes to inherite default color' do
      expect(@test.eyes).to eq('blue')
    end
  end

  describe 'Instance variable access' do
    it 'name to be set and hash access to fail' do
      @test2.name = 'Dux'
      expect(@test2.name).to eq('Dux')
      expect{ @test2[:name]}.to raise_error(NoMethodError)
    end
  end

  describe 'class access' do
    it 'should vanilla check email type' do
      expect{ Typero.validate!('duxdux.net', :email)}.to raise_error
      expect(Typero.validate('duxdux.net', :email)).to eq(false)
      expect(Typero.validate('dux@dux.net', :email)).to eq(true)
    end
  end

  describe Typero::Schema do
    it 'should check against the schema' do
      schema = Typero::Schema.load_schema({
        email: { req: true, type: :email },
        age:   { type: Integer, min: 18, max: 150 }
      })

      res = schema.check({ email:'dux@net.hr', age:'40' }) # ok
      expect(res).to be_nil

      res = schema.check({ email:'duxnet.hr', age:'16' }) # nope, 2 errors
      expect(res[:email]).to be_present
      expect(res[:age]).to be_present
    end
  end
end
