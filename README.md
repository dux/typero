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

#### "date" type - [Typero::DateType](https://github.com/dux/typero/blob/master/lib/typero/type/date.rb)



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


#### "datetime" type - [Typero::DatetimeType](https://github.com/dux/typero/blob/master/lib/typero/type/datetime.rb)



#### "currency" type - [Typero::CurrencyType](https://github.com/dux/typero/blob/master/lib/typero/type/currency.rb)



#### "text" type - [Typero::TextType](https://github.com/dux/typero/blob/master/lib/typero/type/text.rb)



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
* max_value_error - max is %s, got %s
* min_value_error - min is %s, got %s
```
  attributes do
    integer :field, max_value_error: "min is %s, got %s", min_value_error: "min is %s, got %s"
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


#### "point" type - [Typero::PointType](https://github.com/dux/typero/blob/master/lib/typero/type/point.rb)



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


#### "geography" type - [Typero::GeographyType](https://github.com/dux/typero/blob/master/lib/typero/type/geography.rb)


