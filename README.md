## Simple type system

Checks types on save

### Example

```
# with Sequel::Model adapter
Sequel::Model.class_eval do
  def attributes &block
    self.instance_variable_set :@typero_rule, Typero.new(&block)
  end
end

# we can say
class User < Sequel::Model
  attributes do
    string  :name, req:true, min: 3
    email   :email, req: true, uniq: "Email is allready registred", protected: "You are not allowed to change the email"
    float   :speed, min:10, max:200
    integer :age, nil: false
    string  :eyes, default: 'blue'
    integer :maxage, default: lambda { |o| o.age * 5 }
    email   [:emails]  # ensure we have list of emails, field type :email
  end
end
```

### Usage

Can be used in plain, ActiveRecord or Sequel classes.

Can be used as schema validator for custom implementations

```
schema = Typero.new({
  email: { req: true, type: :email },
  age:   { type: Integer, min: 18, max: 150 }
})

# or

schema = Typero.new do
  set :email, req: true, type: :email
  set :age, Integer, min: 18, max: 150
end

# or

schema = Typero.new do
  email   :email, req: true
  integer :age, min: 18, max: 150
end

schema.validate({ email:'dux@net.hr', age:'40' }) # {}
schema.validate({ email:'duxnet.hr', age:'16' })  # {:email=>"Email is missing @", :age=>"Age min is 18, got 16"}
```

### Create custom type

We will create custom type named :label (tag)

```
class Typero::LabelType < Typero::Type
  # default value for blank? == true values
  def default
    nil
  end

  def set value
    value.to_s.gsub(/[^\w\-]/,'')[0,30].downcase
  end

  def validate value
    raise TypeError, "having unallowed characters" unless value =~ /^[\w\-]+$/
    true
  end
end
```

