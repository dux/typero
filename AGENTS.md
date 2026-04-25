# Typero - AI Guide

Typero is a Ruby gem for type coercion and schema validation. It defines field-level types (email, integer, boolean, etc.), coerces values to match, validates constraints, and generates database schemas from type definitions.

## Architecture

```
lib/typero.rb                    # Entry point, requires everything
lib/typero/
  typero.rb                      # Typero module - public API facade
  schema.rb                      # Typero::Schema - validation engine, SCHEMA_STORE
  define.rb                      # Typero::Define - DSL processor for schema blocks
  type/
    type.rb                      # Typero::Type - abstract base class for all types
    geo_extract.rb               # Typero::GeoExtract - shared coord extraction from map URLs
    types/
      string_type.rb             # Each file is one type
      email_type.rb
      integer_type.rb
      ...
lib/adapters/
  sequel.rb                      # Sequel ORM integration (loaded only if Sequel is defined)
```

### Class relationships

- `Typero` module is the public API (`Typero.schema`, `Typero.set`, `Typero.type`)
- `Typero::Schema` wraps a `Typero::Define` instance and provides `validate`, `rules`, `db_schema`, `only`, `except`
- `Typero::Define` processes the DSL block via `method_missing -> set`, stores results in `@rules` hash
- `Typero::Type` is the abstract base; each concrete type overrides `coerce` and `db_schema`

### Type hierarchy

```
Typero::Type
  StringType
    TextType
  IntegerType
  FloatType
    CurrencyType
  BooleanType
  CountryType
  EmailType
  UrlType
  LabelType
  DateType
    DatetimeType
      TimeType
  HashType
  IbanType
  ImageType
  ModelType          # nested schema validation
  PhoneType          # phone number validation
  PointType          # PostGIS geography (includes GeoExtract)
  SimplePointType    # float array point (includes GeoExtract)
  SlugType           # URL-safe slugs
  UuidType           # UUID format validation
  LocaleType
  TimezoneType
  OibType            # Croatian ID number
```

### Type class interface

Each type subclass implements:
- `coerce` - transform the value to the correct type and raise `TypeError` if invalid
- `db_schema` - return `[db_type, opts]` for database column generation
- `default` (optional) - override to provide a non-nil default for blank values
- `input_value` (optional) - override to return a different format than internal `value` (e.g., string instead of array)

Public interface (called externally):
- `initialize(value, opts)` - store value and options
- `get` - returns coerced value (calls `coerce` internally, handles nil/default, returns `input_value`)
- `db_value` - value suitable for DB storage (defaults to `get`, override for special wrapping like `pg_array`)
- `coerce_value` - coerce only, no validation (swallows TypeError from constraint checks). Returns coerced value or nil.
- `input_value` / `to_s` - human-readable string representation of the value
- `set` - alias for `coerce`
- `db_field` - wraps `db_schema` with required/default opts from schema

### Schema validation flow

`Schema#validate` delegates to focused private methods:
- `strip_undefined_keys!` - remove keys not in schema (strict mode)
- `resolve_opts` - dup opts and evaluate any Proc values
- `apply_default` - set default if value is blank
- `read_value` - read from object, normalizing string keys to symbols
- `validate_array` - split, coerce each element, deduplicate, check counts
- `validate_scalar` - check allowed values, coerce via type class, check required
- `coerce_value` - resolve type class via `Type.load`, instantiate, call `db_value`

### Schema definition flow

`Define#set` delegates to focused private methods:
- `parse_args` - extract opts hash from method arguments
- `parse_field_name` - handle `?` suffix for optional fields, normalize required
- `define_block_type` - handle `!` suffix for bulk type assignment
- `resolve_type` - detect Array/Set/boolean/model types and normalize
- `validate_opts` - check all opts are allowed for the given type

## Runtime dependencies

- `Sequel.extension :inflector` provides `.classify` and `.constantize` used throughout for type resolution. This is required.
- `blank?` / `present?` methods on core Ruby objects (provided by ActiveSupport or a polyfill in `spec/lib/blank.rb`)
- `TZInfo` gem only required if using `:timezone` type
- `JSON` stdlib for nested model error handling and hash type parsing

## Public API

### Typero.schema - define and retrieve schemas

```ruby
# Define a named schema (stored in SCHEMA_STORE)
Typero.schema(:user, type: :model) do
  name
  email :email
end

# Define an anonymous schema (not stored)
schema = Typero.schema do
  name
  email :email
end

# Retrieve a named schema
schema = Typero.schema(:user)          # raises if not found
schema = Typero.schema?(:user)         # returns nil if not found

# Query schemas by option
Typero.schema(type: :model)            # returns array of klass name strings
```

Named schemas are stored in `Typero::Schema::SCHEMA_STORE` keyed by the classified name string (`:user` becomes `"User"`, `:api_dyn` becomes `"ApiDyn"`).

### Typero.set / Typero.type - coerce a single value

```ruby
Typero.set(:email, 'DUX@Net.hr')              # => "dux@net.hr"
Typero.set(:integer, '42')                     # => 42
Typero.set(:email, 'bad')                      # raises TypeError
Typero.set(:email, 'bad') { |e| e.message }   # captures error, returns false
Typero.type(:email)                            # returns Typero::EmailType class
```

### Schema validation

```ruby
schema = Typero.schema do
  name
  email :email
end

# validate mutates the object in-place (coerces values, applies defaults)
errors = schema.validate({ name: 'Dux', email: 'dux@net.hr' })
# => {}  (empty hash means valid)

errors = schema.validate({ name: 'Dux', email: 'bad' })
# => { email: "Email is missing @" }

schema.valid?({ name: 'Dux', email: 'dux@net.hr' })  # => true
```

The object passed to `validate` must support `object[field]` and `object[field] = value`. Works with Hash and any object implementing `[]`/`[]=`.

### Schema filtering

```ruby
schema = Typero.schema do
  name
  email :email
  password
  age Integer, default: 21
end

schema.only(:name, :email)                     # new schema with just those fields
schema.except(:password)                       # new schema without those fields
schema.except(:password).only(:name, :email)   # chainable

# returned schemas are fully functional
schema.only(:name).validate(data)
schema.only(:name).rules
schema.only(:name).valid?(data)
```

Both methods accept symbols or strings, return a new `Typero::Schema`, and never mutate the original.

### DB schema generation

```ruby
schema.db_schema
# => [
#   [:name,  :string,  { limit: 255, null: false }],
#   [:email, :string,  { limit: 120, null: false }],
#   [:age,   :integer, { default: 21, null: false }],
# ]
```

## DSL reference

### Field definition

Inside a `Typero.schema` block, every method call becomes a field definition via `method_missing`:

```ruby
Typero.schema do
  # field_name [type], [opts]
  name                           # type: :string, required: true
  email      :email              # type: :email, required: true
  age        Integer             # type: :integer, required: true (Ruby class mapped to symbol)
  speed      :float, min: 10    # type: :float with min constraint
  bio        :text, max: 5000   # type: :text with max constraint

  # explicit set method (useful for reserved words)
  set :class, String
  set :age, Integer, min: 18
end
```

### Required vs optional

```ruby
name                    # required: true (default)
name?                   # required: false (? suffix)
name req: false         # required: false (explicit)
name required: false    # required: false (explicit)
```

### Types with defaults

```ruby
is_active true          # boolean, required: false, default: true
is_locked false         # boolean, required: false, default: false
is_public :boolean      # boolean, required: false, default: false
age Integer, default: 0 # integer with default
```

All boolean variants (`:boolean`, `true`, `false`) default to `required: false`.

### Array fields

```ruby
emails  Array[:email]                    # array of emails, deduplicates by default
tags    Set[:label]                      # same as Array (deduplicates)
emails  Array[:email], duplicates: true  # allow duplicates
tags    Array[:label], max_count: 10     # max 10 elements
skills  Array[:label], min_count: 1      # at least 1 element
```

### Nested schemas

```ruby
# inline block
settings do
  theme
  lang default: 'en'
end

# reference a schema instance
user UserSchema

# schema: keyword
user schema: UserSchema
```

Nested schemas validate with `strict: true` by default (undefined keys are removed). Errors use dot notation: `"settings.theme"`.

### Bulk type assignment

```ruby
integer! do
  org_id
  product_id?
end

false! do
  is_active
  is_locked
end
```

The `!` suffix sets the type for all fields in the block.

### Meta and custom errors

```ruby
name meta: { foo: :bar }
sallary Integer, name: 'Plata', min: 1000, meta: { min_value_error: 'min is %s (%s given)' }
email :email, meta: { unique: true, protected: true }
```

`meta` accepts arbitrary data. Special meta keys used by the Sequel adapter: `:unique`, `:protected`.

### DB-only directives

```ruby
db :timestamps                # appended as [:timestamps]
db :add_index, :code          # appended as [:add_index, :code]
```

## Internal field storage

Fields are stored in `Typero::Define#@rules` as a `Hash<Symbol, Hash>`:

```ruby
{
  name:      { type: :string, required: true },
  email:     { type: :email, required: true },
  age:       { type: :integer, required: true, default: 21, min: 18 },
  tags:      { type: :label, required: true, array: true, max_count: 3 },
  is_active: { type: :boolean, required: false, default: false },
  settings:  { type: :model, required: true, model: #<Typero::Schema> }
}
```

Access via `schema.rules` which returns a duplicate of this hash.

## Error handling

### Error format

Errors hash: `{ field_name: "Error message" }`. Nested model errors use dot paths: `{ :"settings.theme" => "..." }`.

### Error message prefixing

If an error message starts with a lowercase letter, it's auto-prefixed with the field name:
- Field `email`, message `"is missing @"` becomes `"Email is missing @"`
- Custom field name via `name:` opt: field `sallary` with `name: 'Plata'` becomes `"Plata min is 1000"`

### Localized errors

Error messages resolve in order:
1. `opts[:meta][locale][error_key]` (per-field, per-locale)
2. `opts[:meta][error_key]` (per-field, any locale)
3. `Typero::Type::ERRORS[locale][error_key]` (global)

Locale detected from: `Lux.current.locale` > `I18n.locale` > `:en`

## Built-in types quick reference

| Type | Ruby class | Opts | DB type | Notes |
|------|-----------|------|---------|-------|
| string | StringType | min, max, downcase | :string (limit: 255) | default type, max defaults to 255 |
| text | TextType | min, max | :text | no default max (unlike string) |
| integer | IntegerType | min, max | :integer | |
| float | FloatType | min, max, round | :float | |
| currency | CurrencyType | min, max | :decimal (8,2) | always rounds to 2 decimals, supports min/max |
| boolean | BooleanType | | :boolean | truthy: true/1/on, falsy: false/0/off |
| country | CountryType | | :string (limit: 2) | ISO 3166-1 alpha-2, uppercased |
| email | EmailType | | :string (limit: 120) | downcases, checks @ and length |
| url | UrlType | | :string | validates http:// or https:// prefix |
| label | LabelType | | :string (limit: 30) | slug format: lowercase, alphanumeric + hyphens |
| date | DateType | min, max | :date | strips time component, rescues invalid input |
| datetime | DatetimeType | min, max | :timestamp | preserves time, rescues invalid input |
| time | TimeType | min, max | :timestamp | alias for datetime |
| hash | HashType | allow | :jsonb | parses JSON strings via JSON.parse |
| iban | IbanType | | :string (limit: 34) | IBAN validation with MOD-97 checksum |
| image | ImageType | strict | :string | checks http prefix, strips query params for ext check |
| model | ModelType | model/schema | :jsonb | nested schema validation |
| phone | PhoneType | | :string (limit: 50) | normalizes parens/dashes to spaces, min 5 digits |
| point | PointType | | :geography | PostGIS SRID=4326, extracts from Google/OSM/Apple/Waze/Bing URLs |
| simple_point | SimplePointType | | :float (array) | float array [lat, lon], same URL extraction as point, `db_value` wraps with `pg_array` |
| slug | SlugType | max | :string (limit: 255) | URL-safe slug, lowercase, strips special chars |
| uuid | UuidType | | :string (limit: 36) | validates 8-4-4-4-12 hex format, downcases |
| locale | LocaleType | | :string (limit: 5) | validates xx or xx-xx format |
| timezone | TimezoneType | | :string (limit: 50) | validates via TZInfo |
| oib | OibType | | :string (limit: 11) | Croatian ID, ISO 7064 MOD 11,10 checksum, stored as string |

## Sequel adapter

Loaded automatically when `Sequel` is defined. Activate with `Sequel::Model.plugin :typero`.

Adds:
- `schema` class method that wraps `Typero.schema` with `type: :model` and auto-derives name from model class
- `schema` instance method that returns a `Typero::SchemaAccessor` for per-field typed access
- `validate` instance method that runs Typero validation in Sequel's validation lifecycle
- Database-level `:unique` checks (case-insensitive SQL query on column change)
- `:protected` field checks (prevents overwriting after initial creation)

### SchemaAccessor (instance-level)

`model.schema` returns a `Typero::SchemaAccessor`. Methods:

- `model.schema(:name)` - shortcut, returns rules hash for a field (e.g. `{ type: :string, required: true }`)
- `schema[field]` - returns a `Typero::Type` instance seeded with current stored value
- `schema.rules` - returns all rules hash; `schema.rules(:name)` returns rules for a single field
- `schema.get(field)` - returns coerced value via `db_value` (e.g. `schema.get(:location)` => `[44.39, 8.96]`)
- `schema.set(field, value)` - coerces value (no validation) and stores on model via `self[field] =`
- `schema.validate(field)` - validates single field, raises `TypeError` if invalid
- `schema.validate(field) { |err| ... }` - validates single field, yields error message instead of raising
- `schema.validate` - validates all fields, raises `TypeError` on first error
- `schema.validate { |field, err| ... }` - validates all fields, yields each `(field, message)` pair
- `schema.keys` - returns array of field name symbols
- `schema.each { |k, type| ... }` - iterates yielding `(key, type_instance)` pairs

```ruby
mp = MapPoint.last
mp.schema.get(:location)                          # => [44.39, 8.96]
mp.schema.set(:location, "44.39, 8.96")           # coerce + store
mp.schema.validate(:location)                     # raises TypeError if invalid
mp.schema.validate(:location) { |err| puts err }  # captures error
mp.schema.validate                                 # validates all, raises first error
mp.schema.validate { |field, err| puts err }       # validates all, yields each error
```

## Creating custom types

```ruby
class Typero::SlugType < Typero::Type
  # declare type-specific allowed opts
  opts :separator, 'Character used as word separator'

  # register custom error messages
  error :en, :invalid_slug, 'contains invalid characters'

  # coerce and validate the value (required override)
  def coerce
    sep = opts[:separator] || '-'
    value { |data| data.to_s.downcase.gsub(/[^\w#{sep}]/, '').gsub(/#{sep}+/, sep) }
    error_for(:invalid_slug) unless value =~ /^[\w#{sep}]+$/
  end

  # define database column type (required override)
  def db_schema
    [:string, { limit: 100 }]
  end
end
```

Use in schema: `slug :slug, separator: '-'`

## File map

| File | Purpose |
|------|---------|
| lib/typero.rb | Entry point, requires all files |
| lib/typero/typero.rb | `Typero` module public API |
| lib/typero/schema.rb | `Typero::Schema` - validation, rules, only/except, db_schema |
| lib/typero/define.rb | `Typero::Define` - DSL block processor |
| lib/typero/type/type.rb | `Typero::Type` - abstract base, error system, opts system |
| lib/typero/type/geo_extract.rb | `Typero::GeoExtract` - shared coord extraction from map URLs |
| lib/typero/type/types/*.rb | One file per type |
| lib/typero/schema_accessor.rb | `Typero::SchemaAccessor` - instance-level typed field access |
| lib/adapters/sequel.rb | Sequel ORM plugin |
| spec/spec_helper.rb | Test setup, requires Sequel inflector |
| spec/lib/blank.rb | Polyfill for blank?/present? |
| spec/fixtures/all.rb | Test fixtures (Test class, TestSchema) |
| spec/tests/*.rb | Test files |
