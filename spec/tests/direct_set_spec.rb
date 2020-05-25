require 'spec_helper'
require_relative '../fixtures/all'

describe Typero do
  before(:all) do
    @test  = Test.new
    @rules = TestSchema
  end

  describe 'Direct set' do
    it 'expects email in right format' do
      email = 'dUX@NET.hr'
      expect(Typero.set(:email, email)).to eq(email.downcase)
    end

    it 'expects email to raise an error' do
      email = 'dUXNET.hr'
      expect { Typero.set(:email, email) }.to raise_error TypeError
    end

    it 'expects email to raise an error in block' do
      email = 'dUXNET.hr'
      Typero.set(:email, email) { |e| @error = e.message }
      expect(@error).to eq('is missing @')
    end
  end
end
