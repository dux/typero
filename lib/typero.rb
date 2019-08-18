# rules = Typero.new do
#   set :name, String, req: true
#   set :email, :email, req: true
#   set :skills, [:email], min: 2
# end
#
# or
#
# rules = Typero.new do
#   string :name, req: true
#   email :email, req: true
#   email [:skills], min: 2
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
    def validate type, value, opts={}
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

    # check and coerce value
    # Typero.set(:label, 'Foo bar') -> "foo-bar"
    def set type, value, opts={}
      check = Typero::Type.load(type).new value, opts
      check.value
    end
  end

  ###

  # accepts dsl block to
  def initialize hash={}, &block
    @rules = {}
    @db    = []
    hash.each { |k, v| set(k, v) }
    instance_exec &block if block
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
      elsif opts[:required]
        msg = opts[:required].class == TrueClass ? 'is required' : opts[:required]
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

  # returns field, db_type, db_opts
  def db_schema
    out = @rules.inject([]) do |total, (field, opts)|
      type, opts = Typero::Type.load(opts[:type]).new(nil, opts).db_field
      total << [type, field, opts]
    end

    out += @db if @db[0]

    out
  end

  private

  # adds error to array or prefixes with field name
  def add_error field, msg
    if @errors[field]
      @errors[field] += ', %s' % msg
    else
      if msg && msg[0,1].downcase == msg[0,1]
        field_name = field.to_s.sub(/_id$/,'').humanize
        msg = '%s %s' % [field_name, msg]
      end

      @errors[field] = msg
    end
  end

  # used in dsl to define value
  def set field, type=String, opts={}
    field = field.to_sym
    opts  = type.is_a?(Hash) ? type : opts.merge(type: type)
    opts[:type]   ||= :string
    opts[:required] = true if opts[:null].class == FalseClass

    db :add_index, field if opts.delete(:index)

    klass = Typero::Type.load opts[:type]
    @rules[field] = parse_option opts
  end

  def safe_type type
    type.to_s.gsub(/[^\w]/,'').classify
  end

  # coerce opts values
  def parse_option opts
    opts[:type] ||= 'string'

    if opts[:type].is_a?(Array)
       opts[:array_type] = opts[:type][0] if opts[:type][0]
       opts[:type] = 'array'
    end

    opts[:type] = opts[:type].to_s.downcase

    opts[:required]    = opts.delete(:req)  unless opts[:req].nil?
    opts[:unique]      = opts.delete(:uniq) unless opts[:uniq].nil?
    opts[:description] = opts.delete(:desc) unless opts[:desc].nil?

    opts
  end


  # pass values for db_schema only
  # db :timestamps
  # db :add_index, :code -> t.add_index :code
  def db *args
    @db.push args
  end

  def link klass, opts={}
    # TODO: Add can? update check before save
    integer '%s_id' % klass.to_s.tableize.singularize, opts
  end

  def hash name
    set name, :hash
  end

  # set :age, type: :integer -> integer :age
  # email :email
  # set :email, [:emails]
  # email [:emails]
  def method_missing name, *args, &block
    field = args.shift

    if field.class == Array
      field = field.first
      name  = [name]
    end

    name = args.shift if name == :set

    set field, type=name, *args
  end
end

require_relative 'typero/type'

Dir['%s/typero/type/*.rb' % __dir__].each do |file|
  require file
end

# load Sequel adapter is Sequel is available
require_relative './adapters/sequel' if defined?(Sequel)
