# Base class for schema validation.
# Accepts set of params and returns hash of porsed rules

require 'set'
require 'json'

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

      if field.include?('!')
        if block
          field = field.sub('!', '')
          @block_type = field.to_sym
          instance_exec &block
          @block_type = nil
          return
        else
          raise ArgumentError.new 'If you use ! you have to provide a block'
        end
      end

      # name? - opional name
      if field.include?('?')
        field = field.sub('?', '')
        opts[:required] = false
      end

      opts[:required] = opts.delete(:req) unless opts[:req].nil?
      opts[:required] = true if opts[:required].nil?

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

      opts[:type] = @block_type if @block_type

      # Boolean
      if opts[:type].is_a?(TrueClass) || opts[:type] == :true
        opts[:required] = false
        opts[:default]  = true
        opts[:type]     = :boolean
      elsif opts[:type].is_a?(FalseClass) || opts[:type] == :false || opts[:type] == :boolean
        opts[:required] = false if opts[:required].nil?
        opts[:default]  = false if opts[:default].nil?
        opts[:type]     = :boolean
      end

      # model / schema
      if opts[:type].class.ancestors.include?(Typero::Schema)
        opts[:model] = opts.delete(:type)
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
      opts.keys.each do |key|
        type = Typero::Type.load opts[:type]
        type.allowed_opt?(key) {|err| raise ArgumentError, err }
      end

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
      @db_rules.push args.unshift(:db_rule!)
    end

    # if method undefine, call set method
    # age Integer -> set :age, type: :integer
    # email Array[:emails] -> set :emails, Array[:email]
    def method_missing field, *args, &block
      set field, *args, &block
    end
  end
end
