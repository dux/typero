## Simple type system

### Example

```
class Test
  include Typero::Hash      # keep attributes in Hash instead of instance attributes
  include Typero::Instance  # import class.attribute method for defineing types

  attribute :name
  attribute :speed, type: Float, min:10, max:200
  attribute :email, :email, req: true, uniq:'Email is allready regstred'
  attribute :age, Integer, nil: false
  attribute :eyes, default: 'blue'
  attribute :maxage, :default=>lambda { |o| o.age * 5 }
  attribute :emails, Array[:email]
  attribute :tags, Array[:label]
end


test = Test.new
test.email = 'foo@bar.baz' # ok
test.email = 'foobar.baz'  # nope, raises TypeError

```

### Usage

Can be used in plain, ActiveRecord or Sequel classes.

Can be used as schema validator for custom implementations

```
schema = Typero::Schema.load_schema({ email: { req: true, type: :email }, age: { type: Integer, min: 18, max: 150 }})
schema.check { email:'dux@net.hr', age:'40' } # ok
schema.check { email:'duxnet.hr', age:'16' } # nope, 2 errors
```