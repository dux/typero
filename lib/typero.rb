require_relative './typero/instance'
require_relative './typero/schema'
require_relative './typero/type'
require_relative './typero/hash'

Dir["#{File.dirname(__FILE__)}/typero/type/*.rb"].each{ |f| load f }

# attribute :url, :url
# attribute :name, req:'Link name is required'
# attribute :tags, Array[:label]
# attribute :bucket_id, Integer, req:'Bucket is not assigned'
# attribute :kind, String, allow:[:doc, :img, :vid, :lnk, :art], default:'lnk'
# attribute :email, :email, req:true, uniq:"Email is allready registred", protected:"You are not allowed to change the email"

# Typero.validate('dux@dux.net', :email)

module Typero
  extend self

  @opts ||= {}

  def opts
    @opts
  end

  # called to define instance variable in class
  # Typero.define_instance(self, :email, { :type=>:email })
  def define_instance(klass, name, opts={})
    type = opts[:type]
    opts[:name] = name

    type_klass = "Typero::#{type.to_s.classify}Type".constantize
    @opts[klass.to_s] ||= {}
    @opts[klass.to_s][name] = type_klass.new(opts).freeze

    klass.class_eval %[
      def #{name}
        Typero.opts['#{klass}'][:#{name}].get_value(self)
      end

      def #{name}=(value=nil)
        Typero.opts['#{klass}'][:#{name}].set_value(self, value)
      end
    ]
  end

  def last_error
    Thread.current[:validate_last_error]
  end

  # Typero.validate('duxdux.net', :email) # raise erorr
  # Typero.validate('duxdux.net', :email) { |msg| error(msg) } # capture
  def validate!(value, type, opts={}, &block)
    type_klass = "Typero::#{type.to_s.classify}Type".constantize
    type_klass.new(opts).validate(value)
    true
  rescue TypeError
    if block
      block.call($!.message)
      return false
    end
    raise(TypeError, $!.message)
  end

  # Typero.validate('duxdux.net', :email) -> false
  def validate(*args)
    validate!(*args)
    true
  rescue
    false
  end

  # Typero.quick_set('[invalid-to-fix]', :label)
  def quick_set(value, type, opts={})
    type_klass = "Typero::#{type.to_s.classify}Type".constantize
    type_inst  = type_klass.new(opts)
    type_inst.respond_to?(:get_set) ? type_inst.get_set(value) : set(value)
  end


  # Typero.validate_opts params, :ttl, :password
  # only :ttl, :password and allowed in hash
  def validate_opts(hash, *args)
    for key in (hash || {}).keys
      raise TypeError, "Key :#{key} is not allowed in hash" unless args.index(key)
    end
    hash
  end
end

