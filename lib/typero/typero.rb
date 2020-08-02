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

  # load type schema
  def schema name=nil, &block
    # :user -> 'User'
    name = name.to_s.classify if name

    if block_given?
      Typero::Schema.new(&block).tap do |schema|
        Typero::Schema::SCHEMAS[name] = schema if name
      end
    else
      raise ArgumentError.new('Schema name not given') unless name

      schema   = Typero::Schema::SCHEMAS[name]
      schema ||= class_finder name, :schema
      schema || nil
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
