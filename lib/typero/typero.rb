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
    check.set
    check.validate
    check.value
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
      raise ArgumentErorr.new('Schema nema not given') unless name

      schema   = Typero::Schema::SCHEMAS[name]
      schema ||= proc do
        # 'User\ -> if UserSchema is defined, return that
        klass = name + 'Schema'
        defined?(klass) && klass.constantize
      end.call

      schema || raise(ArgumentErorr.new('Typero schema "%s" not defined' % name))
    end
  end
end
