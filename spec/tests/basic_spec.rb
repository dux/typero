require 'spec_helper'
require_relative '../fixtures/all'

describe Typero do
  before(:all) do
    @test  = Test.new
    @rules = TestSchema
  end

  describe 'Hash access' do
    it 'speed should be Float' do
      @test.speed = '10'
      errors = @rules.validate(@test)
      expect(@test.speed.class).to eq(Float)
      expect(@test.speed).to eq(10.0)
    end

    it 'speed min and max should be respected' do
      @test.speed = 5
      errors = @rules.validate(@test)
      expect(errors[:speed].length > 5).to be_truthy

      @test.speed = 555
      errors = @rules.validate(@test)
      expect(errors[:speed].length > 5).to be_truthy

      @test.speed = 100
      errors = @rules.validate(@test)
      expect(errors[:speed]).to eq(nil)
    end

    it 'name should be string' do
      @test.name = :dino
      @rules.valid? @test
      expect(@test.name).to eq('dino')
    end

    it 'name should allow null name' do
      @test.name = ''
      @rules.valid? @test
      expect(@test.name).to eq(nil)
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

    it 'email in array to fail and then pass' do
      @test.emails = ['dux@dux.net', 'duxdux.net']
      errors = @rules.validate(@test)
      expect(errors[:emails].include?('@')).to be_truthy

      @test.emails = ['dux@dux.net', 'dux2@dix.net']
      errors = @rules.validate(@test)
      expect(errors[:emails]).to be_nil
    end

    it 'label in array to fail' do
       @test.tags = ['foo@bar','baz']
       @rules.validate(@test)
       expect(@test.tags.first).to eq('foobar')
    end

    it 'label in array to pass' do
       @test.tags = ['foo','bar']
       @rules.validate(@test)
       expect(@test.tags).to eq(['foo','bar'])
    end

    it 'should not allow email nil' do
      @test.email     = 'dux@net.hr'
      @test.email_nil = nil
      errors = @rules.validate(@test)
      expect(errors[:email_nil]).to be_nil
      expect(errors[:email]).to be_nil
    end

    it 'age to be 20' do
      @test.age = '20'
      @rules.validate(@test)
      expect(@test.age).to eq(20)
    end

    it 'expect eyes to inherite default color' do
      @rules.validate(@test)
      expect(@test.eyes).to eq('blue')
    end

    it 'raises error when type not found' do
      expect do
        Typero.new do
          kinky  :name
        end
      end.to raise_error ArgumentError
    end
  end
end
