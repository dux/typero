# Base class for schema validation

module Typero
  class Params
    attr_reader :db_rules

    def initialize &block
      @db_rules = []
      @rules    = {}
      instance_exec &block
    end

    def rules
      @rules.dup
    end

    private

    # used in dsl to define schema field options
    def set field, *args, &block
      raise "Field name not given (Typero)" unless field

      if args.first.is_a?(Hash)
        opts = args.first || {}
      else
        opts = args[1] || {}
        opts[:type] ||= args[0]
      end

      opts[:type] = :string if opts[:type].nil?

      field = field.to_s

      # name? - opional name
      if field.include?('?')
        field = field.sub('?', '')
        opts[:required] = false
      end

      if value = opts.delete(:req)
        opts[:required] = value
      else
        opts[:required] = true if opts[:required].nil?
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

      # Boolean
      if opts[:type].is_a?(TrueClass)
        opts[:required] = false
        opts[:default]  = true
        opts[:type]     = :boolean
      elsif opts[:type].is_a?(FalseClass)
        opts[:required] = false
        opts[:default]  = false
        opts[:type]     = :boolean
      end

      opts[:model] = opts.delete(:schema) if opts[:schema]
      opts[:type]  = :model if opts[:model]

      if block_given?
        opts[:type]  = :model
        opts[:model] = Typero.schema &block
      end

      opts[:type] ||= 'string'
      opts[:type]   = opts[:type].to_s.downcase.to_sym

      opts[:description] = opts.delete(:desc) unless opts[:desc].nil?

      # chek alloed params, all optional should go in meta
      result = opts.keys - Typero::Type::OPTS_KEYS
      raise ArgumentError.new('Unallowed Type params found: "%s", allowed: %s' % [result.join(' and '), Typero::Type::OPTS_KEYS.sort]) if result.length > 0

      field = field.to_sym

      db :add_index, field if opts.delete(:index)

      # trigger error if type not found
      Typero::Type.load opts[:type]

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
      set field, *args, &block
    end
  end
end