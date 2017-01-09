## Simple type system

Checks types on set, not on save. No checks on read for fast access.


### Example

```
class Test
  include Typero::Hash      # keep attributes in Hash instead of instance attributes
  include Typero::Instance  # import class.attribute method for defineing types

  attribute :name
  attribute :speed, type: Float, min:10, max:200
  attribute :email, :email, req: true, uniq:'Email is allready regstred'
  attribute :emails, Array[:email]  # create list of emails
  attribute :age, Integer, nil: false
  attribute :eyes, default: 'blue'
  attribute :maxage, default: lambda { |o| o.age * 5 }
  attribute :tags,   Array[:label]  # create list of tags
end


test = Test.new
test.email = 'foo@bar.baz' # ok
test.email = 'foobar.baz'  # nope, raises TypeError

class User < Sequel::Model
  attribute :name, String, req:true, min: 3
  attribute :email, :email, req: true, uniq: "Email is allready registred", protected: "You are not allowed to change the email"
end
```

### Usage

Can be used in plain, ActiveRecord or Sequel classes.

Can be used as schema validator for custom implementations

```
schema = Typero::Schema.load_schema({
  email: { req: true, type: :email },
  age:   { type: Integer, min: 18, max: 150 }
})
schema.check { email:'dux@net.hr', age:'40' } # ok
schema.check { email:'duxnet.hr', age:'16' } # nope, 2 errors
```

### Create custom type

We will create custom type named :label (tag)

```
module Typero
  class LabelType < Typero::Type
    # default value for blank? == true values
    def default
      nil
    end

    def set(value)
      value.to_s.gsub(/[^\w\-]/,'')[0,30].downcase
    end

    def validate(value)
      raise TypeError, "having unallowed characters" unless value =~ /^[\w\-]+$/
      true
    end
  end
end
```

