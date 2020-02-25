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
  SCHEMAS = {}
  VERSION = File.read File.expand_path '../../.version', File.dirname(__FILE__)

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

    # def schema table_name, &block
    #   schema = Typero.new(&block)

    #   if Lux.config.migrate
    #     AutoMigrate.typero table_name, schema
    #   else
    #     klass = table_name.to_s.classify.constantize
    #     klass.typero = schema
    #   end
    # end
  end

  ###

  # accepts dsl block to
  def initialize name=nil, &block
    if block_given?
      @schema = Schema.new &block

      if name
        SCHEMAS[name_fix(name)] = @schema
      end
    elsif name
      schema_name = name_fix(name)
      @schema = SCHEMAS[schema_name] || raise(ArgumentError.new('Schema nemed "%s" not found (%s)' % [schema_name, name]))
    else
      raise ArgumentError, 'No block or schema name given'
    end
  end

  # validates any instance object or object with hash variable interface
  # it also coarces values
  def validate instance
    @errors = {}

    @schema.rules.each do |field, opts|
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
    out = @schema.rules.inject([]) do |total, (field, opts)|
      type, opts = Typero::Type.load(opts[:type]).new(nil, opts).db_field
      total << [type, field, opts]
    end

    out += @db if @db[0]

    out
  end

  # iterate trough all the ruels via block interface
  # schema.rules do |field, opts|
  # schema.rules(:url) do |field, opts|
  def rules filter=nil, &block
    return @schema.rules unless filter
    out = @schema.rules
    out = out.select { |k,v| v[:type].to_s == filter.to_s || v[:array_type].to_s == filter.to_s } if filter
    return out unless block_given?

    for k, v in out
      yield k, v
    end
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

  def safe_type type
    type.to_s.gsub(/[^\w]/,'').classify
  end

  def name_fix name
    if name.is_a?(Symbol)
      name.to_s.classify if name.is_a?(Symbol)
    else
      name.to_s
    end
  end
end

