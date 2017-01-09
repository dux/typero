require_relative './lib/typero'
require 'active_support/core_ext/string' unless respond_to?(:capitalize)

class Test
  include Typero::Hash
  include Typero::Instance

  attribute :name
  attribute :speed, type: Float, min:10, max:200
  attribute :email, :email, req: true
  attribute :email_nil, :email
  attribute :emails, Array[:email]
  attribute :age, Integer, nil:false
  attribute :eyes, default:'blue'
  attribute :maxage, default: lambda { |o| o.age * 5 }
  attribute :tags, Array[:label]
end

t = Test.new
t.emails = ['rejotl@gmail.com', 'duxnet.hr']

p t.emails