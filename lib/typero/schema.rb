module Typero
  class Schema
    SCHEMAS = {}

    # accepts dsl block to
    def initialize &block
      raise "Params not defined" unless block_given?
      @schema = Params.new &block
    end

    # validates any instance object with hash variable interface
    # it also coarces values
    def validate object
      @object = object
      @errors = {}

      @schema.rules.each do |field, opts|
        # set value to default if value is blank and default given
        @object[field] = opts[:default] if opts[:default] && @object[field].blank?

        # get field value
        value = @object[field]

        if opts[:array]
          unless value.is_a?(Array)
            opts[:delimiter] ||= /\s*,\s*/
            value = value.to_s.split(opts[:delimiter])
          end

          value = value
            .map { |el| check_filed_value field, el, opts }
            .map { |el| el.to_s == '' ? nil : el }
            .compact

          value = Set.new(value).to_a unless opts[:duplicates]

          opts[:max_count] ||= 100
          add_error(field, 'Max number of array elements is %d, you have %d' % [opts[:max_count], value.length], opts) if value.length > opts[:max_count]

          add_required_error field, value.first, opts
        else
          value = check_filed_value field, value, opts
          add_required_error field, value, opts
        end

        # if value is not list of allowed values, raise error
        if opts[:allowed] && !opts[:values].include?(value)
          add_error field, 'Value "%s" is not allowed' % value, opts
        end

        # present empty string values as nil
        @object[field] = value.to_s.sub(/\s+/, '') == '' ? nil : value
      end

      if @errors.keys.length > 0 && block_given?
        @errors.each { |k, v| yield(k, v) }
      end

      @errors
    end

    def valid? object
      errors = validate object
      errors.keys.length == 0
    end

    # returns field, db_type, db_opts
    def db_schema
      out = @schema.rules.inject([]) do |total, (field, opts)|
        # get db filed schema
        type, opts  = Typero::Type.load(opts[:type]).new(nil, opts).db_field

        # add array true to field it ont defined in schema
        schema_opts = @schema.rules[field]
        opts[:array] = true if schema_opts[:array]

        total << [type, field, opts]
      end

      out += @schema.db_rules

      out
    end

    # iterate trough all the ruels via block interface
    # schema.rules do |field, opts|
    # schema.rules(:url) do |field, opts|
    def rules filter = nil, &block
      return @schema.rules unless filter
      out = @schema.rules
      out = out.select { |k, v| v[:type].to_s == filter.to_s || v[:array_type].to_s == filter.to_s } if filter
      return out unless block_given?

      out.each { |k, v| yield k, v }
    end
    alias :to_h :rules

    private

    # adds error to array or prefixes with field name
    def add_error field, msg, opts
      if @errors[field]
        @errors[field] += ", %s" % msg
      else
        if msg && msg[0, 1].downcase == msg[0, 1]
          field_name = opts[:name] || field.to_s.sub(/_id$/, "").capitalize
          msg = "%s %s" % [field_name, msg]
        end

        @errors[field] = msg
      end
    end

    def safe_type type
      type.to_s.gsub(/[^\w]/, "").classify
    end

    def add_required_error field, value, opts
      return unless opts[:required] && value.nil?
      msg = opts[:required].class == TrueClass ? "is required" : opts[:required]
      add_error field, msg, opts
    end

    def check_filed_value field, value, opts
      klass = "Typero::%sType" % safe_type(opts[:type])
      check = klass.constantize.new value, opts
      check.get
    rescue TypeError => e
      if e.message[0] == '{'
        for key, msg in JSON.parse(e.message)
          add_error [field, key].join('.'), msg, opts
        end
      else
        add_error field, e.message, opts
      end
    end
  end
end
