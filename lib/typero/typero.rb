# module quick qcess tp other types

module Typero
  extend self

  VERSION ||= File.read File.expand_path "../../.version", File.dirname(__FILE__)

  # check and coerce value
  # Typero.type(:label) -> Typero::LabelType
  # Typero.type(:label, 'Foo bar') -> "foo-bar"
  def type klass_name, value = :_undefined, opts = {}, &block
    klass = Typero::Type.load(klass_name)

    if value == :_undefined
      klass
    else
      begin
        check = klass.new value, opts
        check.get
      rescue TypeError => error
        if block
          block.call error
          false
        else
          raise error
        end
      end
    end
  end
  alias :set :type

  # type schema
  # Typero.schema(:blog) { ... }

  # type schema with option
  # Typero.schema(:blog, type: :model) { ... }

  # get schema
  # Typero.schema(:blog)

  # get all schema that matches any option
  # Typero.schema(type: :model)
  def schema name = nil, opts = nil, &block
    klass = name.to_s.classify if name && !name.is_a?(Hash)

    if block_given?
      # Typero.schema type: :model, db: DB_LOG do
      Typero::Schema.new(klass, opts, &block)
    else
      if name.is_a?(Hash)
        # Schema not given, get schema
        #   Typero.schema type: :model
        out = []

        for schema in Schema::SCHEMA_STORE.values
          if schema.opts[name.keys.first] == name.values.first
            out.push schema.klass
          end
        end

        out
      else
        # Typero.schema :user
        Typero::Schema::SCHEMA_STORE[klass] || raise('Schema "%s" not found' % klass)
      end
    end
  end

  # get array of database fields, ruby Sequel compatibile
  def db_schema name
    Typero.schema(name).db_schema
  end

  def defined? name
    Typero::Type.load name
    true
  rescue ArgumentError
    false
  end
end
