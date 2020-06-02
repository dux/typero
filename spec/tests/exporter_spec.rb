require 'spec_helper'

###

Company = Struct.new(:name, :address) do
  def creator
    User.new('dux', 'dux@.net.hr')
  end

  def user
    User.new('dux', 'dux@.net.hr')
  end
end

User = Struct.new(:name, :email) do
  def company
    Company.new('ACME', 'Nowhere 123')
  end
end

Typero.export :company do
  prop :name
  prop :address

  prop :creator, export(model.user)
end

Typero.export :company_naked do
  prop :name
  response[:foo] = :bar
end

Typero.export :user do
  export :company

  prop :name
  prop :email
  prop :is_admin do
    user && user.name.include?('dux')
  end
end

###

describe Typero::Exporter do
  it 'expects basic export to work' do
    name    = 'ACME 1'
    address = 'Nowhere 123'

    company = Company.new(name, address)
    result  = Typero.export(company)

    expect(result[:name]).to eq(name)
    expect(result[:address]).to eq(address)
  end

  it 'exports complex object' do
    user     = User.new 'dux', 'dux@net.hr'
    response = Typero.export user, user: user
    expect(response[:is_admin]).to eq(true)

    user     = User.new 'dino', 'dux@net.hr'
    response = Typero.export user, user
    expect(response[:is_admin]).to eq(false)
  end

  it 'exports naked object' do
    company = Company.new('ACME 1', 'Nowhere 123')
    data = Typero.export company, exporter: :company_naked
    expect(data[:address]).to be_nil
    expect(data[:foo]).to be(:bar)
  end

  it 'exports deep if needed' do
    user     = User.new 'dux', 'dux@net.hr'
    response = Typero.export user, user: user, depth: 3
    expect(response[:company][:creator][:company][:name]).to eq('ACME')
  end
end
