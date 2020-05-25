class Typero
  SCHEMAS = {}
end

def Typero name=nil, &block
  # :user -> 'User'
  name = name.to_s.classify if name

  if block_given?
    Typero.new(&block).tap do |schema|
      Typero::SCHEMAS[name] = schema if name
    end
  else
    raise ArgumentErorr.new('Schema nema not given') unless name

    schema   = Typero::SCHEMAS[name]
    schema ||= proc do
      # 'User\ -> if UserSchema is defined, return that
      klass = name + 'Schema'
      defined?(klass) && klass.constantize
    end.call

    schema || raise(ArgumentErorr.new('Typero schema "%s" not defined' % name))
  end
end