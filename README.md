## Typero - custom types and schema validations

Typero is lib for type coercion and schema validation.

Instead of having DB schema, you can model your data on real types and generate db_schema, forms, API validators and other based on given types.

Errors are localized.

```ruby
UserSchema = Typero.schema do
  name       max: 100
  email      :email
  interests  Set[:label]
  location   :point
end

UserSchema.rules           # rules hash
UserSchema.db_schema       # generate DB schema
UserSchema.validate @user  # validate data
```

You can coerce and validate a single value

```ruby
good_email = 'DUX@Net.hr'

# will convert email to 'dux@net.hr' (lowercase)
Typero.set :email, good_email

bad_email = 'duxnet.hr'

# raises TypeError
Typero.set :email, bad_email

# will capture error if block provided
Typero.set(:email, bad_email) { |e| @error = e.message }
```

### Installation

`gem install typero`

or in Gemfile

`gem 'typero'`

and to use

`require 'typero'`

### Schema definition

```ruby
schema = Typero.schema do
  # default type is String
  name    min: 3

  # unique info
  email   :email, unique: 'Email is already registered'

  # min and max can be defined for numbers and strings
  speed   :float, min: 10, max: 200

  # use values to define all possible values for a property
  eyes    default: 'blue', values: %w(brown blue green)

  # array type can be defined for any value
  # duplicates are removed by default
  emails  Array[:email], duplicates: true, max_count: 5
  emails  Set[:email]

  # manually set field and value for reserved words
  set :set, String

  # non required fields are defined by ?
  name? # same as "name required: false"

  # meta attributes can accept any value
  name meta: { foo: :bar, baz: 113 } # ok
  name foo: :bar # ArgumentError

  # you can set custom field names and error messages
  # @object.sallary = 500 # error - 'Plata min is 1000 (500 given)'
  sallary  Integer, name: 'Plata', min: 1000, meta: { en: { min_value_error: 'min is %s (%s given)'} }
  # or without locale prefix
  sallary  Integer, name: 'Plata', min: 1000, meta: { min_value_error: 'min is %s (%s given)' }
end
```

### Usage

Can be used in plain, ActiveRecord (adapter missing) or Sequel classes.

Can be used as schema validator for custom implementations.

```ruby
schema = Typero.schema do
  email   :email, req: true
  set     :age, Integer, min: 18, max: 150
end

schema.validate({ email:'dux@net.hr', age:'40' }) # {}
schema.validate({ email:'duxnet.hr', age:'16' })  # {:email=>"Email is missing @", :age=>"Age min is 18, got 16"}
```

You can define schemas in several ways

```ruby
# as an anonymous schema
schema = Typero.schema do
  user_name
end

# as a named schema (stored in SCHEMA_STORE)
Typero.schema(:user) do
  user_name
end

# retrieve a named schema
schema = Typero.schema(:user)

# returns nil if not found (instead of raising)
schema = Typero.schema?(:user)
```

### Nested schemas

```ruby
# create schema
UserSchema = Typero.schema do
  name
  email  :email
  avatar? :url
end

# reference by schema instance
Typero.schema :api1 do
  bar
  foo Integer

  user UserSchema

  # or dynamic declaration
  user do
    name
    email :email
    avatar? :url
  end
end
```

### Schema filtering with `only` and `except`

You can derive a new schema from an existing one by selecting or excluding fields. Both methods return a new `Typero::Schema` instance that supports validation, rules, and chaining.

```ruby
UserSchema = Typero.schema do
  name
  email      :email
  password
  age        Integer, default: 21
  is_active  false
end

# keep only specific fields
UserSchema.only(:name, :email)

# remove specific fields
UserSchema.except(:password)

# chaining
UserSchema.except(:password).only(:name, :email)

# the returned schema is fully functional
schema = UserSchema.only(:name, :email)
errors = schema.validate({ name: 'Dux', email: 'dux@net.hr' })

# works with nested schemas too
ProfileSchema = Typero.schema do
  name
  settings do
    theme
    lang default: 'en'
  end
end

ProfileSchema.only(:settings)  # nested model field preserved with all its rules
```

String keys are accepted and converted to symbols automatically. The original schema is never mutated.

### Bulk type assignment

Types can be assigned in bulk using the `!` suffix with a block.

Notice that any attribute value can be a Proc. If it is, it will be evaluated at runtime inside the scope of the given object.

```ruby
Typero.schema :bulk do
  integer! do
    org_id        req: proc { I18n.t('org.required') }
    product_id?
  end

  false! do
    is_active
    is_locked
  end
end
```

### Built in types

* #### boolean
  Converts common truthy/falsy strings to true or false.
  ```ruby
  Typero.set :boolean, 'on'   # => true
  Typero.set :boolean, '0'    # => false
  ```

* #### currency
  Rounds float to 2 decimal places for monetary values.
  ```ruby
  Typero.set :currency, 123.456  # => 123.46
  ```

* #### date
  Parses date strings and strips time component.
  ```ruby
  Typero.set :date, '2024-12-25 14:30'  # => Date(2024-12-25)
  ```
  Opts: `min`, `max`

* #### datetime / time
  Parses datetime strings, preserves time component.
  ```ruby
  Typero.set :datetime, '2024-12-25 14:30'  # => Time(2024-12-25 14:30:00)
  ```
  Opts: `min`, `max`

* #### email
  Downcases and normalizes email addresses, validates @ presence and min length.
  ```ruby
  Typero.set :email, 'DUX@Net.hr'  # => "dux@net.hr"
  ```

* #### float
  Converts to float with optional rounding.
  ```ruby
  Typero.set :float, '3.14159', round: 2  # => 3.14
  ```
  Opts: `min`, `max`, `round`

* #### hash
  Parses JSON strings to hash, validates hash type.
  ```ruby
  Typero.set :hash, '{"a":1}'  # => {"a"=>1}
  ```
  Opts: `allow`

* #### image
  Validates image URLs, optionally checks extension.
  ```ruby
  Typero.set :image, 'https://example.com/photo.jpg'  # => "https://example.com/photo.jpg"
  ```
  Opts: `strict`

* #### integer
  Converts to integer with min/max validation.
  ```ruby
  Typero.set :integer, '42'  # => 42
  ```
  Opts: `min`, `max`

* #### label
  Creates lowercase alphanumeric labels with hyphens, max 30 chars.
  ```ruby
  Typero.set :label, 'My Tag Name!'  # => "my-tag-name"
  ```

* #### locale
  Validates locale format (xx or xx-xx).
  ```ruby
  Typero.set :locale, 'en-US'  # => "en-US"
  ```

* #### model
  Validates nested hash against another schema.
  ```ruby
  Typero.set :model, { name: 'Dux' }, schema: UserSchema
  ```

* #### oib
  Validates Croatian personal ID number (ISO 7064 MOD 11,10 checksum).
  ```ruby
  Typero.set :oib, '12345678901'  # => "12345678901" (if valid checksum)
  ```

* #### phone
  Normalizes phone formatting to spaces, validates min 5 digits.
  ```ruby
  Typero.set :phone, '+1 (555) 123-4567'  # => "+1 555 123 4567"
  ```

* #### point
  PostGIS geography point (SRID=4326), extracts coords from Google/OSM/Apple/Waze/Bing map URLs.
  ```ruby
  Typero.set :point, 'https://maps.google.com/maps?q=45.815,15.9819'
  # => "SRID=4326;POINT(15.9819 45.815)"
  ```

* #### simple_point
  Float array [lat, lon], extracts coords from map URLs, returns formatted string.
  ```ruby
  Typero.set :simple_point, 'https://maps.google.com/maps?q=45.815,15.9819'
  # => "45.815, 15.9819"
  ```

* #### slug
  URL-safe slug, lowercase, replaces special chars with hyphens.
  ```ruby
  Typero.set :slug, 'My Blog Post!'  # => "my-blog-post"
  ```
  Opts: `max`

* #### string
  Basic string with length validation, max defaults to 255.
  ```ruby
  Typero.set :string, 'Hello World', max: 10  # => "Hello Worl"
  ```
  Opts: `min`, `max`, `downcase`

* #### text
  Unlimited string length for long content.
  ```ruby
  Typero.set :text, 'Long article content...'  # => "Long article content..."
  ```
  Opts: `min`, `max`

* #### timezone
  Validates timezone string via TZInfo.
  ```ruby
  Typero.set :timezone, 'Europe/Zagreb'  # => "Europe/Zagreb"
  ```

* #### url
  Validates http or https URL prefix.
  ```ruby
  Typero.set :url, 'example.com/page'  # raises error (missing http)
  ```

* #### uuid
  Validates and downcases UUID format (8-4-4-4-12).
  ```ruby
  Typero.set :uuid, 'A1B2C3D4-E5F6-7890-ABCD-EF1234567890'
  # => "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
  ```

### Create custom type

Each type implements `coerce` (transform and validate the value) and `db_schema` (return database column definition). Optionally override `input_value` to return a different format than the internal value.

```ruby
class Typero::LabelType < Typero::Type
  # default value for blank? == true values
  def default
    nil
  end

  # coerce the value - transform and validate
  def coerce
    value do |data|
      data.to_s.gsub(/[^\w\-]/,'')[0,30].downcase
    end

    error_for(:unallowed_characters_error) unless value =~ /^[\w\-]+$/
  end

  # define database column type
  def db_schema
    [:string, { limit: 30 }]
  end
end
```

#### Override input_value

Use `input_value` when internal storage differs from output format:

```ruby
class Typero::SimplePointType < Typero::Type
  def coerce
    value { extract_coords(value) }  # stores array [lat, lon]
  end

  def input_value
    value.join(', ')  # returns "lat, lon" string
  end

  def db_schema
    [:float, { array: true }]  # DB stores array
  end
end
```

### Errors

If you want to overload errors or add new languages.

```ruby
Typero::Type.error :en, :min_length_error, 'min length is %s, you have defined %s'
```

#### Built in errors

```ruby
ERRORS = {
  en: {
    min_length_error: 'min length is %s, you have %s',
    max_length_error: 'max length is %s, you have %s',
    min_value_error: 'min is %s, got %s',
    max_value_error: 'max is %s, got %s',
    unallowed_characters_error: 'is having unallowed characters',
    not_in_range: 'Value is not in allowed range (%s)',
    unsupported_boolean: 'Unsupported boolean param value: %s',
    min_date: 'Minimal allowed date is %s',
    max_date: 'Maximal allowed date is %s',
    not_8_chars_error: 'is not having at least 8 characters',
    missing_monkey_error: 'is missing @',
    not_hash_type_error: 'value is not hash type',
    image_not_starting_error: 'URL is not starting with http',
    image_not_image_format: 'URL is not ending with jpg, jpeg, gif, png, svg, webp',
    locale_bad_format: 'Locale "%s" is in bad format (should be xx or xx-xx)',
    not_an_oib_error: 'not in an OIB format',
    invalid_time_zone: 'Invalid time zone',
    url_not_starting_error: 'URL is not starting with http or https',
    invalid_phone: 'is not a valid phone number',
    invalid_uuid: 'is not a valid UUID',
    invalid_slug: 'contains invalid characters',
  }
}
```
