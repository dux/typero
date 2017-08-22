require_relative './lib/typero'
require 'active_support/core_ext/string' unless respond_to?(:capitalize)

schema = Typero.new({
  email: { req: true, type: :email },
  age:   { type: Integer, min: 18, max: 150 }
})

# or

schema = Typero.new do
  set :email, req: true, type: :email
  set :age, Integer, min: 18, max: 150
end

schema.validate({ email:'dux@net.hr', age:'40' }) # {}
schema.validate({ email:'duxnet.hr', age:'16' })  # {:email=>"Email is missing @", :age=>"Age min is 18, got 16"}

# puts errors
