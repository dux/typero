## Typero - custom types and schema validations

Typero is lib for custom types and schema validations.

Instead of haveing DB schema, you can model your data on real types and geneate db_schema, forms, API validators and other based on given types.

Errors are localized

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

You can test single value

```ruby
good_email = 'DUX@Net.hr'

# will convert email to 'dux@net.hr' (lowercase)
# but it will not raise error
Typero.set :email, good_email

bad_email = 'duxnet.hr'

# raises TypeError
Typero.set :email, bad_email

# will capture error if block provided
Typero.set(:email, bad_email) { |e| @error = e.message }
```

### Schema example

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
  sallary  Integer, name: 'Plata', min: 1000, meta: { en: { min_value_error: 'min is %s (%s given)'} }
  # or without locale prefix
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

### Built in types

* **image** - [Typero::ImageType](https://github.com/dux/typero/blob/master/lib/typero/type/types/image.rb)
  * `strict: Force image to have known extension (jpg, jpeg, gif, png, svg, webp)`
* **date** - [Typero::DateType](https://github.com/dux/typero/blob/master/lib/typero/type/types/date.rb)
* **string** - [Typero::StringType](https://github.com/dux/typero/blob/master/lib/typero/type/types/string.rb)
  * `min: Minimun string length`
  * `max: Maximun string length`
* **oib** - [Typero::OibType](https://github.com/dux/typero/blob/master/lib/typero/type/types/oib.rb)
* **datetime** - [Typero::DatetimeType](https://github.com/dux/typero/blob/master/lib/typero/type/types/datetime.rb)
* **currency** - [Typero::CurrencyType](https://github.com/dux/typero/blob/master/lib/typero/type/types/currency.rb)
* **text** - [Typero::TextType](https://github.com/dux/typero/blob/master/lib/typero/type/types/text.rb)
  * `min: Minimun string length`
  * `max: Maximun string length`
* **label** - [Typero::LabelType](https://github.com/dux/typero/blob/master/lib/typero/type/types/label.rb)
* **email** - [Typero::EmailType](https://github.com/dux/typero/blob/master/lib/typero/type/types/email.rb)
* **integer** - [Typero::IntegerType](https://github.com/dux/typero/blob/master/lib/typero/type/types/integer.rb)
  * `min: Minimum value`
  * `max: Maximun value`
* **hash** - [Typero::HashType](https://github.com/dux/typero/blob/master/lib/typero/type/types/hash.rb)
* **url** - [Typero::UrlType](https://github.com/dux/typero/blob/master/lib/typero/type/types/url.rb)
* **point** - [Typero::PointType](https://github.com/dux/typero/blob/master/lib/typero/type/types/point.rb)
* **boolean** - [Typero::BooleanType](https://github.com/dux/typero/blob/master/lib/typero/type/types/boolean.rb)
* **float** - [Typero::FloatType](https://github.com/dux/typero/blob/master/lib/typero/type/types/float.rb)
  * `min: Minimum value`
  * `max: Maximun value`

### Create custom type

We will create custom type named :label

```ruby
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

### Errors

If you want to overload errors or add new languages.

```ruby
Typero::Type.error :en, :min_length_error, 'minimun lenght is %s, you have defined %s'
```

#### Built in errors

```ruby
ERRORS = {
  en: {
    min_length_error: 'min lenght is %s, you have %s',
    max_length_error: 'max lenght is %s, you have %s',
    min_value_error: 'min is %s, got %s',
    max_value_error: 'max is %s, got %s',
    unallowed_characters_error: 'is having unallowed characters',
    image_not_starting_error: 'URL is not starting with http',
    image_not_image_format: 'URL is not ending with jpg, jpeg, gif, png, svg, webp',
    not_an_oib_error: 'not in an OIB format',
    not_8_chars_error: 'is not having at least 8 characters',
    missing_monkey_error: 'is missing @',
    not_hash_type_error: 'value is not hash type',
    url_not_starting_error: 'URL is not starting with http',
  }
}
```