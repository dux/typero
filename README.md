## Typero - custom types and schema validations

Typero is lib for custom types and schema validations.

Instead of haveing DB schema, you can model your data on real types and geneate db_schema, forms, API validators and other based on given types.

Errors are localized

```ruby
UserSchema = Typero do
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
UserSchema = Typero do
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

  # manualy set field and value for protected fields
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

### Installation

to install

`gem install typero`

or in Gemfile

`gem 'typero'`

and to use

`require 'typero'`

### Usage

Can be used in plain, ActiveRecord (adapter missing) or Sequel classes.

Can be used as schema validator for custom implementations

```ruby
schema = Typero do
  email   :email, req: true
  integer :age,   min: 18, max: 150 #, min_error: "Minimal allowed age is 18 years."
end

# or

schema = Typero do
  set :email, req: true, type: :email
  set :age, Integer, min: 18, max: 150
end

schema.validate({ email:'dux@net.hr', age:'40' }) # {}
schema.validate({ email:'duxnet.hr', age:'16' })  # {:email=>"Email is missing @", :age=>"Age min is 18, got 16"}
```

You can define schemas in many ways

```ruby
# as a instance
schema = Typero.new { user_name }

# as a instance, shorter
schema = Typero { user_name }

# via cached schema
Typero(:user) { user_name }
schema = Typero(:user)

# via class schema
# Typero(:user) will return UserSchema if one present
UserSchema = Typero do { user_name }
schema = Typero(:user)
UserSchema.validate(@user)
schema.validate(@user)
```

### Nested schemas

```ruby
# create model
Typero.schema User do
  name
  email  :email
  avatar :url
end

# reference by model
Typero.schema :api1 do
  # root params
  bar
  foo  Integer

  # hash has to match the model
  user  model: User

  # or dynamic declaration
  user do
    name
    email :email
    avatar :url
  end
end

```

### Advanced - bulk type define and function access

Types can be assigned in a bulk, you just neeed to pass a block and end type with "!"

Example numberos booleans with default false + integers

Notice that any attribute can be a function. If it is, it will be evaluated at runtime inside the scope of given object.

```ruby
Typero.schema :bulk do
  integer! do
    org_id        req: proc { I18n.t('org.required') }
    prroduct_id?
  do

  false! do
    is_active
    is_locked
  end
end
```

### Built in types

* **boolean** - [Typero::BooleanType](https://github.com/dux/typero/blob/master/lib/typero/type/types/boolean_type.rb)
* **currency** - [Typero::CurrencyType](https://github.com/dux/typero/blob/master/lib/typero/type/types/currency_type.rb)
* **date** - [Typero::DateType](https://github.com/dux/typero/blob/master/lib/typero/type/types/date_type.rb)
* **datetime** - [Typero::DatetimeType](https://github.com/dux/typero/blob/master/lib/typero/type/types/datetime_type.rb)
* **email** - [Typero::EmailType](https://github.com/dux/typero/blob/master/lib/typero/type/types/email_type.rb)
* **float** - [Typero::FloatType](https://github.com/dux/typero/blob/master/lib/typero/type/types/float_type.rb)
  * `min: Minimum value`
  * `max: Maximun value`
  * `round: Round to (decimal spaces)`
* **hash** - [Typero::HashType](https://github.com/dux/typero/blob/master/lib/typero/type/types/hash_type.rb)
* **image** - [Typero::ImageType](https://github.com/dux/typero/blob/master/lib/typero/type/types/image_type.rb)
  * `strict: Force image to have known extension (jpg, jpeg, gif, png, svg, webp)`
* **integer** - [Typero::IntegerType](https://github.com/dux/typero/blob/master/lib/typero/type/types/integer_type.rb)
  * `min: Minimum value`
  * `max: Maximun value`
* **label** - [Typero::LabelType](https://github.com/dux/typero/blob/master/lib/typero/type/types/label_type.rb)
* **locale** - [Typero::LocaleType](https://github.com/dux/typero/blob/master/lib/typero/type/types/locale_type.rb)
* **model** - [Typero::ModelType](https://github.com/dux/typero/blob/master/lib/typero/type/types/model_type.rb)
* **oib** - [Typero::OibType](https://github.com/dux/typero/blob/master/lib/typero/type/types/oib_type.rb)
* **point** - [Typero::PointType](https://github.com/dux/typero/blob/master/lib/typero/type/types/point_type.rb)
* **string** - [Typero::StringType](https://github.com/dux/typero/blob/master/lib/typero/type/types/string_type.rb)
  * `min: Minimun string length`
  * `max: Maximun string length`
  * `downcase: is the string in downcase?`
* **text** - [Typero::TextType](https://github.com/dux/typero/blob/master/lib/typero/type/types/text_type.rb)
  * `min: Minimun string length`
  * `max: Maximun string length`
* **time** - [Typero::TimeType](https://github.com/dux/typero/blob/master/lib/typero/type/types/time_type.rb)
* **timezone** - [Typero::TimezoneType](https://github.com/dux/typero/blob/master/lib/typero/type/types/timezone_type.rb)
* **url** - [Typero::UrlType](https://github.com/dux/typero/blob/master/lib/typero/type/types/url_type.rb)

### Create custom type

We will create custom type named :label

```ruby
class Typero::LabelType < Typero::Type
  # default value for blank? == true values
  def default
    nil
  end

  def set
    value do |data|
      data.to_s.gsub(/[^\w\-]/,'')[0,30].downcase
    end
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
    not_in_range: 'Value in not in allowed range (%s)',
    min_date: 'Minimal allowed date is %s',
    max_date: 'Maximal allowed date is %s',
    unsupported_boolean: 'Unsupported boolean param value: %s',
    url_not_starting_error: 'URL is not starting with http or https',
    locale_bad_format: 'Locale "%s" is in bad format (should be xx or xx-xx)',
    not_hash_type_error: 'value is not hash type',
    invalid_time_zone: 'Invalid time zone',
    image_not_starting_error: 'URL is not starting with http',
    image_not_image_format: 'URL is not ending with jpg, jpeg, gif, png, svg, webp',
    not_8_chars_error: 'is not having at least 8 characters',
    missing_monkey_error: 'is missing @',
    not_an_oib_error: 'not in an OIB format',
  }
}
```