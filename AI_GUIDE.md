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
- `Typero::Type` is the abstract base; each concrete type (e.g., `Typero::EmailType`) overrides `set` and `db_schema`

### Type hierarchy

```
Typero::Type
  StringType
    TextType
  IntegerType
  FloatType
    CurrencyType
  BooleanType
  EmailType
  UrlType
  LabelType
  DateType
    DatetimeType
      TimeType
  HashType
  ImageType
  ModelType          # nested schema validation
  PointType          # PostGIS geography
  SimplePointType    # float array point
  LocaleType
  TimezoneType
  OibType            # Croatian ID number
```

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
age Integer, default: 0 # integer with default
```

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
db :timestamps                # appended as [:db_rule!, :timestamps]
db :add_index, :code          # appended as [:db_rule!, :add_index, :code]
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

## Validation flow

When `schema.validate(object)` is called:

1. If `strict: true` and object is a Hash, delete keys not in schema
2. For each field in rules:
   a. Evaluate any Proc values in opts (via `object.instance_exec(&proc)`)
   b. Apply default if value is blank and default exists
   c. Read value from object (normalizes string keys to symbols for Hash)
   d. For arrays: split strings by delimiter, coerce each element, deduplicate, check count constraints
   e. For scalars: check allowed values whitelist, coerce via type class, check required
   f. Write coerced value back to object (empty strings become nil)
3. Return errors hash (empty = valid)

### Type coercion (inside step 2d/2e)

The type class is resolved from the `:type` symbol: `:email` -> `Typero::EmailType`. An instance is created with the value and opts, then `get` is called:

- If value is nil: return `opts[:default]` or `type.default`
- Otherwise: call `type.set` (subclass override that coerces and validates), check `:values` whitelist, return value

If `set` raises `TypeError`, the error is captured and added to the errors hash.

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
| string | StringType | min, max, downcase | :string (limit: 255) | default type |
| text | TextType | min, max | :text | inherits StringType |
| integer | IntegerType | min, max | :integer | |
| float | FloatType | min, max, round | :float | |
| currency | CurrencyType | | :decimal (8,2) | always rounds to 2 decimals |
| boolean | BooleanType | | :boolean | truthy: true/1/on, falsy: false/0/off |
| email | EmailType | | :string (limit: 120) | downcases, checks @ and length |
| url | UrlType | | :string | checks http/https prefix |
| label | LabelType | | :string (limit: 30) | slug format: lowercase, alphanumeric + hyphens |
| date | DateType | min, max | :date | strips time component |
| datetime | DatetimeType | min, max | :timestamp | preserves time |
| time | TimeType | min, max | :timestamp | alias for datetime |
| hash | HashType | allow | :jsonb | parses JSON strings, removes empty values |
| image | ImageType | strict | :string | checks http prefix, optionally checks extension |
| model | ModelType | model/schema | :jsonb | nested schema validation |
| point | PointType | | :geography | PostGIS SRID=4326 format |
| simple_point | SimplePointType | | :float (array) | float array [lat, lng] |
| locale | LocaleType | | :string (limit: 5) | validates xx or xx-xx format |
| timezone | TimezoneType | | :string (limit: 50) | validates via TZInfo |
| oib | OibType | | :string (limit: 11) | Croatian ID, ISO 7064 MOD 11,10 checksum |

## Sequel adapter

Loaded automatically when `Sequel` is defined. Activate with `Sequel::Model.plugin :typero`.

Adds:
- `schema` class method that wraps `Typero.schema` with `type: :model` and auto-derives name from model class
- `validate` instance method that runs Typero validation in Sequel's validation lifecycle
- Database-level `:unique` checks (case-insensitive SQL query on column change)
- `:protected` field checks (prevents overwriting after initial creation)

## Creating custom types

```ruby
class Typero::SlugType < Typero::Type
  # declare type-specific allowed opts
  opts :separator, 'Character used as word separator'

  # register custom error messages
  error :en, :invalid_slug, 'contains invalid characters'

  # coerce and validate the value (required override)
  def set
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
| lib/typero/type/types/*.rb | One file per type |
| lib/adapters/sequel.rb | Sequel ORM plugin |
| spec/spec_helper.rb | Test setup, requires Sequel inflector |
| spec/lib/blank.rb | Polyfill for blank?/present? |
| spec/fixtures/all.rb | Test fixtures (Test class, TestSchema) |
| spec/tests/*.rb | Test files |
