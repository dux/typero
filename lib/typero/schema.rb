# Base class for schema validation

class Typero
  class Schema
    attr_accessor :rules

    def initialize &block
      @db    = []
      @rules = {}
      instance_exec &block
    end

    private

    # used in dsl to define value
    def set field, type=String, opts={}
      raise "Field name not given (Typero)" unless field

      field = field.to_sym
      opts  = type.is_a?(Hash) ? type : opts.merge(type: type)
      opts[:type]   ||= :string
      opts[:required] = true if opts[:null].class == FalseClass

      db :add_index, field if opts.delete(:index)

      klass = Typero::Type.load opts[:type]
      @rules[field] = parse_option opts
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
      klass.is! Class

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
end