## Simple type system

Checks types on save

### Example

```
# we can say
class User < Sequel::Model
  attributes do
    string  :name, req:true, min: 3
    email   :email, req: true, uniq: "Email is allready registred", protected: "You are not allowed to change the email"
    float   :speed, min:10, max:200
    integer :age, nil: false
    string  :eyes, default: 'blue'
    integer :maxage, default: lambda { |o| o.age * 5 }
    email   [:emails] # ensure we have list of emails, field type :email

    db :timestamps
    db :add_index, :email
  end
end

# and we can generate DB schema
User.typero.db_schema
# [:name, :string, {:limit=>255, :null=>false}],
# [:email, :string, {:limit=>120, :null=>false}],
# [:speed, :float, {}],
# [:age, :integer, {}],
# [:eyes, :string, {:limit=>255}],
# [:maxage, :integer, {}],
# [:emails, :string, {:limit=>120, :array=>true}],
# [:timestamps],
# [:add_index, :email]

User.typero.rules
# Hash
# {
#   "name": {
#     "type": "string",
#     "required": "City name is required"
#   },
#   "lon_lat": {
#     "type": "point"
#   },
  ```

### Usage

Can be used in plain, ActiveRecord (adapter missing) or Sequel classes.

Can be used as schema validator for custom implementations

```ruby
schema = Typero.new do
  email   :email, req: true
  integer :age,   min: 18, max: 150 #, min_error: "Minimal allowed age is 18 years."
end

# or

schema = Typero.new do
  set :email, req: true, type: :email
  set :age, Integer, min: 18, max: 150
end

# or

schema = Typero.new({
  email: { req: true, type: :email },
  age:   { type: Integer, min: 18, max: 150 }
})

schema.validate({ email:'dux@net.hr', age:'40' }) # {}
schema.validate({ email:'duxnet.hr', age:'16' })  # {:email=>"Email is missing @", :age=>"Age min is 18, got 16"}
```

### Create custom type

We will create custom type named :label

```
class Typero::LabelType < Typero::Type
  # default value for blank? == true values
  def default
    nil
  end

  def set
    @value.to_s.gsub(/[^\w\-]/,'')[0,30].downcase
  end

  def validate
    raise TypeError, "having unallowed characters" unless @value =~ /^[\w\-]+$/
    true
  end
end
```

### Built in types and errors

{{types}}