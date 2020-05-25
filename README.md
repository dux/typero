## Typero - custom types and schema validations

Typero is lib for custom types and schema validations.

Instead of haveing DB schema, you can model your data on real types and geneate db_schema, forms, API validators and other based on given types.

```ruby
UserSchema = Typero.new do
  name       max: 100
  email      :email
  interests  Set[:label]
  location   :point
end

UserSchema.rules           # rules hash
UserSchema.db_schema       # generate DB schema
UserSchema.validate @user  # validate data
```

### Example

```ruby
# we can say
UserSchema = Typero.new do
  # default type is String
  name    min: 3 # default type is String

  # unique info
  email   :email, unique: 'Email is allready registred'

  # min and max length can be defined for numbers and strings
  speed   :float, min:10, max:200

  # use values to define all possible values for a property
  eyes    default: 'blue', values: %w(brown blue green)

  # array type can be defined for any value
  # duplicates are false by defult
  emails  Array[:email], duplicates: true, max_length: 5
  emails  Set[:email]

  # manualy set field and value for protected fileds
  set :set, String

  # non required fields are defined by ?
  name? # same as "name required: false"

  # meta attributes can accept any value
  name meta: { foo: :bar, baz: 113 } # ok
  name foo: :bar # ArgumentError

  # you can set custome filed names and error messages
  # @object.sallary = 500 # erorr - 'Plata min is 1000 (500 given)'
  sallary  Integer, name: 'Plata', min: 1000, meta: { min_value_error: 'min is %s (%s given)' }
end
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
    # allow only strnings
    raise TypeError.neew("having unallowed characters") unless @value =~ /^\w+$/
    true
  end
end
```

### Built in types and errors

#### "image" type - [Typero::ImageType](https://github.com/dux/typero/blob/master/lib/typero/type/image.rb)

errors
* not_starting_error - URL is not starting with http
```
  attributes do
    image :field, not_starting_error: "URL is not starting with http"
  end
```


#### "date" type - [Typero::DateType](https://github.com/dux/typero/blob/master/lib/typero/type/date.rb)



#### "string" type - [Typero::StringType](https://github.com/dux/typero/blob/master/lib/typero/type/string.rb)

errors
* min_length_error - min lenght is %s, you have %s
* max_length_error - max lenght is %s, you have %s
```
  attributes do
    string :field, min_length_error: "max lenght is %s, you have %s", max_length_error: "max lenght is %s, you have %s"
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


#### "point" type - [Typero::PointType](https://github.com/dux/typero/blob/master/lib/typero/type/point.rb)



#### "boolean" type - [Typero::BooleanType](https://github.com/dux/typero/blob/master/lib/typero/type/boolean.rb)



#### "float" type - [Typero::FloatType](https://github.com/dux/typero/blob/master/lib/typero/type/float.rb)

errors
* min_length_error - min lenght is %s
* max_length_error - max lenght is %s
```
  attributes do
    float :field, min_length_error: "max lenght is %s", max_length_error: "max lenght is %s"
  end
```

