# Base class for schema validation

module Typero
  class Params
    ALLOWED = %i(name min max default allowed delimiter max_count req required type array meta desc description duplicates unique)

    attr_reader :rules, :db_rules

    def initialize &block
      @db_rules = []
      @rules    = {}
      instance_exec &block
    end

    private

    # used in dsl to define schema field options
    def set field, *args
      raise "Field name not given (Typero)" unless field

      if args.first.is_a?(Hash)
        opts = args.first || {}
      else
        opts = args[1] || {}
        opts[:type] ||= args[0]
      end

      opts[:type]   ||= :string
      opts[:required] = true unless opts[:required].is_a?(FalseClass) || opts[:req].is_a?(FalseClass)

      field = field.to_s

      # name? - opional name
      if field.include?('?')
        field = field.sub('?', '')
        opts[:required] = false
      end

      # array that allows duplicates
      if opts[:type].is_a?(Array)
        opts[:type]  = opts[:type].first
        opts[:array] = true
      end

      # no duplicates array
      if opts[:type].is_a?(Set)
        opts[:type]  = opts[:type].to_a.first
        opts[:array] = true
      end

      opts[:type] ||= 'string'
      opts[:type]   = opts[:type].to_s.downcase

      opts[:description] = opts.delete(:desc) unless opts[:desc].nil?

      # chek alloed params, all optional should go in meta
      result = opts.keys - ALLOWED
      raise ArgumentError.new('Unallowed Type params found: %s, allowed: %s' % [result.join(', '), ALLOWED]) if result.length > 0

      field = field.to_sym

      db :add_index, field if opts.delete(:index)

      klass = Typero::Type.load opts[:type]
      @rules[field] = opts
    end

    # pass values for db_schema only
    # db :timestamps
    # db :add_index, :code -> t.add_index :code
    def db *args
      @db_rules.push args
    end

    # set :age, type: :integer -> integer :age
    # email :email
    #
    # set :emails, Array[:email]
    # email Array[:emails]
    def method_missing field, *args, &block
      set field, *args
    end
  end
end