# str = Typero::StringType.new(req:true, default:'Miki')
# str.set_value('Dino')
# puts str.get_value

# str = Typero::EmailType.new()
# str.set_value('dux|at|dux.net') -> raises eror
module Typero
  class Type
    attr_accessor :opts

    ### SAFE TO OVERLOAD: START

    # if value is not blank, it is sent to set method
    def set(value)
      value
    end

    # sometimes we want to coarce values on get
    # by default just copy
    def get(list)
      list
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
      if value.nil?
        if @opts[:default]
          @opts[:default].class.to_s == 'Proc' ? @opts[:default].call(instance) : @opts[:default]
        else
          return default
        end
      else
        get(value)
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
          not_unique = false
          if instance.respond_to?(:is_unique_field?)
            not_unique = !instance.is_unique_field?(@name, value)
          else
            filter = instance.class.select(:id).where("#{@name}=?", value)
            filter = filter.where('id<>?', instance.id) if instance.id
            not_unique = true if filter.first
          end
          raise TypeError, @opts[:uniq].class == TrueClass ? %[Field #{@name} is uniqe and value "#{value}" allready exists] : @opts[:uniq] if not_unique
        end

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


