## Simple type system

Checks types on save

### Example

We can say

```ruby
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

```ruby
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
  integer :age, min: 18, max: 150 #, min_error: "Minimal allowed age is 18 years."
end

schema.validate({ email:'dux@net.hr', age:'40' }) # {}
schema.validate({ email:'duxnet.hr', age:'16' })  # {:email=>"Email is missing @", :age=>"Age min is 18, got 16"}
```

### Create custom type

We will create custom type named :label (tag)

```ruby
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

### Implement in Sequel or ActiveRecord

Save block and check schema in before_save filter

Example for Sequel

```ruby
# with Sequel::Model adapter
class Sequel::Model
  module ClassMethods
    def attributes &block
      self.instance_variable_set :@typero, Typero.new(&block)
    end

    def typero
      self.instance_variable_get :@typero
    end
  end


  module InstanceMethods
    # calling typero! on any object will validate all fields
    def check_attributes
      typero = self.class.typero || return

      typero.validate(self) do |name, err|
        errors.add(name, err) unless (errors.on(name) || []).include?(err)
      end
    end

    def validate
      check_attributes
      super
    end
  end
end
```

### Built in types and errors

#### "string" type - [Typero::StringType](https://github.com/dux/typero/blob/master/lib/typero/type/string.rb)

errors
* max_length_error - max lenght is %s, you have %s
* min_length_error - min lenght is %s, you have %s
```
  attributes do
    string :field, max_length_error: "min lenght is %s, you have %s", min_length_error: "min lenght is %s, you have %s"
  end
```


#### "oib" type - [Typero::OibType](https://github.com/dux/typero/blob/master/lib/typero/type/oib.rb)

errors
* not_an_oib_error - not in an OIB format
```
  attributes do
    oib :field, not_an_oib_error: "not in an OIB format"
  end
```


#### "array" type - [Typero::ArrayType](https://github.com/dux/typero/blob/master/lib/typero/type/array.rb)

errors
* value_in_list_error - value in list
* min_error - min array lenght is %s elements
* max_error - max array lenght is %s elements
```
  attributes do
    array :field, value_in_list_error: "max array lenght is %s elements", min_error: "max array lenght is %s elements", max_error: "max array lenght is %s elements"
  end
```


#### "label" type - [Typero::LabelType](https://github.com/dux/typero/blob/master/lib/typero/type/label.rb)

errors
* unallowed_characters_error - label is having unallowed characters
```
  attributes do
    label :field, unallowed_characters_error: "label is having unallowed characters"
  end
```


#### "email" type - [Typero::EmailType](https://github.com/dux/typero/blob/master/lib/typero/type/email.rb)

errors
* not_8_chars_error - is not having at least 8 characters
* missing_monkey_error - is missing @
```
  attributes do
    email :field, not_8_chars_error: "is missing @", missing_monkey_error: "is missing @"
  end
```


#### "integer" type - [Typero::IntegerType](https://github.com/dux/typero/blob/master/lib/typero/type/integer.rb)

errors
* min_value_error - min is %s, got %s
* max_value_error - max is %s, got %s
```
  attributes do
    integer :field, min_value_error: "max is %s, got %s", max_value_error: "max is %s, got %s"
  end
```


#### "hash" type - [Typero::HashType](https://github.com/dux/typero/blob/master/lib/typero/type/hash.rb)

errors
* not_hash_type_error - value is not hash type
```
  attributes do
    hash :field, not_hash_type_error: "value is not hash type"
  end
```


#### "url" type - [Typero::UrlType](https://github.com/dux/typero/blob/master/lib/typero/type/url.rb)

errors
* not_starting_error - URL is not starting with http
```
  attributes do
    url :field, not_starting_error: "URL is not starting with http"
  end
```


#### "boolean" type - [Typero::BooleanType](https://github.com/dux/typero/blob/master/lib/typero/type/boolean.rb)



#### "float" type - [Typero::FloatType](https://github.com/dux/typero/blob/master/lib/typero/type/float.rb)

errors
* max_length_error - max lenght is %s
* min_length_error - min lenght is %s
```
  attributes do
    float :field, max_length_error: "min lenght is %s", min_length_error: "min lenght is %s"
  end
```

