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

  VERSION = File.read File.expand_path "../../.version", File.dirname(__FILE__)

  # check and coerce value
  # Typero.set(:label, 'Foo bar') -> "foo-bar"
  def set type, value, opts = {}, &block
    check = Typero::Type.load(type).new value, opts
    check.get
  rescue TypeError => error
    if block
      block.call error
      false
    else
      raise error
    end
  end

  # load or set type schema
  # Typero.schema(:blog) { ... }
  # Typero.schema(:blog, type: :model) { ... }
  # Typero.schema(:blog)
  # Typero.schema(type: :model)
  def schema name=nil, opts=nil, &block
    klass = name.to_s.classify if name && !name.is_a?(Hash)

    if block_given?
      Typero::Schema.new(&block).tap do |schema|
        if klass
          Typero::Schema::SCHEMAS[klass] = schema

          if opts && opts[:type]
            Typero::Schema::TYPES[opts[:type]] ||= []
            Typero::Schema::TYPES[opts[:type]].push klass unless Typero::Schema::TYPES[opts[:type]].include?(klass)
          end
        end
      end
    else
      # Schema not given, get schema
      if name.is_a?(Hash)
        # Typero.schema type: :model
        if type = name[:type]
          Typero::Schema::TYPES[type]
        end
      elsif klass
        # Typero.schema :user
        schema   = Typero::Schema::SCHEMAS[klass]
        schema ||= class_finder klass, :schema
        schema || nil
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
