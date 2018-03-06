# rules = Typero.new do
#   set :name, String, req: true
#   set :email, :email, req: true
#   set :skills, [:email], min: 2
# end
#
# errors = rules.validate @object
# rules.valid?
# rules.validate(@object) { |errors| ... }

class Typero
  attr_reader :rules

  VERSION = File.read File.expand_path '../.version', File.dirname(__FILE__)

  class << self
    # validate single value in type
    def validate value, type, opts={}
      field = type.to_s.tableize.singularize.to_sym

      # we need to have pointer to hash, so value can be changed (coerced) if needed
      h = { field => value }

      rule = new
      rule.set field, type, opts

      if error = rule.validate(h)[field]
        block_given? ? yield(error) : raise(TypeError.new(error))
      end

      h[field]
    end

    # Typero.set(:label, 'Foo bar') -> "foo-bar"
    def set type, value, opts={}
      klass = 'Typero::%sType' % type.to_s.gsub(/[^\w]/,'').classify
      check = klass.constantize.new value, opts
      check.set
    end

    def cache
      @@cache ||= {}
    end
  end

  ###

  # accepts dsl block to
  def initialize hash={}, &block
    @rules = {}
    hash.each { |k, v| set(k, v) }
    instance_exec &block if block
  end

  # convert
  # integer :age
  # set :age, type: :integer
  # email :email
  # set :email, [:emails]
  # email [:emails]
  def method_missing name, *args, &block
    field = args.shift

    if field.class == Array
      field = field.first
      name  = [name]
    end

    set field, type=name, *args
  end

  # coerce opts values
  def parse_option opts
    opts[:type] ||= 'string'
    opts[:req] = opts.delete(:required) unless opts[:required].nil?

    if opts[:type].is_a?(Array)
       opts[:array_type] = opts[:type][0] if opts[:type][0]
       opts[:type] = 'array'
    end

    opts[:type] = opts[:type].to_s.downcase

    allowed_names = [:req, :uniq, :protected, :type, :min, :max, :array_type, :default, :downcase, :desc]
    opts.keys.each do |key|
      raise ArgumentError.new('%s is not allowed as typero option' % key) unless allowed_names.index(key)
    end

    opts
  end

  # used in dsl to define value
  def set field, type=String, opts={}
    klass = '::Typero::%sType' % type.to_s.gsub(/[^\w]/,'').classify
    klass.constantize

    opts = type.is_a?(Hash) ? type : opts.merge(type: type)

    @rules[field] = parse_option opts
  end

  def safe_type type
    type.to_s.gsub(/[^\w]/,'').classify
  end

  # adds error to array or prefixes with field name
  def add_error field, msg
    if @errors[field]
      @errors[field] += ', %s' % msg
    else
      field_name = field.to_s.sub(/_id$/,'').humanize
      @errors[field] = '%s %s' % [field_name, msg]
    end
  end

  # validates any instance object or object with hash variable interface
  # it also coarces values
  def validate instance
    @errors = {}

    @rules.each do |field, opts|
      # set value to default if value is blank and default given
      instance[field] = opts[:default] if opts[:default] && instance[field].blank?

      # get field value
      value = instance[field]

      if value.present?
        klass = 'Typero::%sType' % safe_type(opts[:type])
        check = klass.constantize.new value, opts
        check.value = check.default if check.value.nil?

        unless check.value.nil?
          begin
            check.set
            check.validate
            instance[field] = check.value
          rescue TypeError => e
            add_error field, e.message
          end
        end
      elsif opts[:req]
        msg = opts[:req].class == TrueClass ? 'is required' : opts[:req]
        add_error field, msg
      end
    end

    if @errors.keys.length > 0 && block_given?
      @errors.each { |k,v| yield(k, v) }
    end

    @errors
  end

  def valid? instance
    errors = validate instance
    errors.keys.length == 0
  end
end

require_relative 'typero/type'

Dir['%s/typero/type/*.rb' % File.dirname(__FILE__)].each { |file| require file }
