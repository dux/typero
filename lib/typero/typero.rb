# rules = Typero.schema do
#   set :name, String, req: true
#   set :email, :email, req: true
#   set :skills, [:email], min: 2
# end
#
# or
#
# rules = Typero.schema do
#   string :name, req: true
#   email :email, req: true
#   email [:skills], min: 2
# end
#
# errors = rules.validate @object
# rules.valid?
# rules.validate(@object) { |errors| ... }

module Typero
  extend self

  VERSION ||= File.read File.expand_path "../../.version", File.dirname(__FILE__)
  SCHEMAS ||= {}

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

  # get schema with options (as array)
  # Typero.schema(:blog, :with_schema)

  # get all schema names with type: model
  # Typero.schema(type: :model)
  def schema name = nil, opts = nil, &block
    klass = name.to_s.classify if name && !name.is_a?(Hash)

    if block_given?
      Typero::Schema.new(&block).tap do |schema|
        if klass
          SCHEMAS[klass] = [schema, opts || {}]
        end
      end
    else
      # Schema not given, get schema
      if name.is_a?(Hash)
        # Typero.schema type: :model
        out = []

        for key, _ in SCHEMAS
          schema, opts = _
          next unless opts[name.keys.first] == name.values.first
          out.push key.classify
        end

        out
      elsif klass
        # Typero.schema :user
        schema   = SCHEMAS[klass]
        schema ||= class_finder klass, :schema

        if opts
          schema
        else
          schema.respond_to?(:[]) ? schema[0] : schema
        end
      else
        raise ArgumentError, 'Schema type not defined.'
      end
    end
  end

  def defined? name
    Typero::Type.load name
    true
  rescue ArgumentError
    false
  end

  private

  # class_finder :user, :exporter, :representer
  # find first UserExporter, User::Exporter, User::Representer, UserRepresenter
  def class_finder *args
    name = args.shift.to_s.classify

    for el in args
      for separator in ['_','/']
        klass = [name, el].join(separator).classify
        return klass.constantize if const_defined? klass
      end
    end

    nil
  end
end
