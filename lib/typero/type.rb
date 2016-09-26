# str = Typero::StringType.new(req:true, default:'Miki')
# str.set_value('Dino')
# puts str.get_value

# str = Typero::EmailType.new()
# str.set_value('dux|at|dux.net') -> raises eror
module Typero
  class Type
    attr_accessor :opts

    ### SAFE TO OVERLOAD: START

    # default min implementation
    def min(value, length)
      raise TypeError, "Min #{@type} lenght for #{@name} is #{length}, you have #{value.to_s.length}" if value.to_s.length  < length
    end

    # default max implementation
    def max(value, length)
      raise TypeError, "Max #{@type} length for #{@name} is #{length}, you have #{value.to_s.length}" if value.to_s.length  > length
    end

    # if value is not blank, it is sent to set method
    def set(value)
      value
    end

    # if value is blank?, trigger default
    # for example set it to false for boolean type and [] for array type
    def default
      nil
    end

    # default validation for any type
    def validate(what)
      true
    end

    ### SAFE TO OVERLOAD: END

    # set options
    def initialize(opts={})
      @type = self.class.to_s.split('::')[1].sub('Type','').downcase.to_sym
      @opts = opts
      @name = opts.delete(:name)
    end

    def check_type(type)
      type_klass = "Typero::#{type.to_s.classify}Type"
      (type_klass.constantize rescue false) ? true : false
    end

    def get_value(instance)
      # get current var value
      value = instance.respond_to?('[]') ? instance[@name] : instance.instance_variable_get("@#{@name}")
      if value.blank?
        # if blank check for default
        if @opts[:default]
          @opts[:default].class.to_s == 'Proc' ? @opts[:default].call(instance) : @opts[:default]
        else
          return default
        end
      else
        value
      end
    end

    def set_value(instance, value=nil)
      if !value.blank?
        # for user emails, once defined cant be overitten
        if @opts[:protected] && get_value(instance) && get_value(instance) != value
          raise TypeError, @opts[:protected].class == TrueClass ? "#{@name.capitalize} is allready defined and can't be overwritten." : @opts[:protected]
        end

        value = set(value)

        # search for unique fields on set, say for email
        # so it is not checked on save, it is checked on set
        if @opts[:uniq]
          filter = instance.class.select(:id).where("#{@name}=?", value)
          filter = filter.where('id<>?', instance.id) if instance.id
          raise TypeError, @opts[:uniq].class == TrueClass ? "Field #{@name} is uniqe and allready exists" : @opts[:uniq] if filter.first
        end

        min(value, @opts[:min]) if @opts[:min]
        max(value, @opts[:max]) if @opts[:max]

        validate(value)
      elsif @opts[:req]
        msg = @opts[:req].class == TrueClass ? "is required" : @opts[:req]
        raise TypeError, msg
      else
        value = default
      end

      if instance.respond_to?('[]')
        # save to hash by default
        instance[@name] = value
      else
        # fallback to instance variable if no hash (plain class, not AR or Sequel)
        instance.instance_variable_set("@#{@name}", value)
      end
    end
  end
end


