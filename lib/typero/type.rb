# Master class

class Typero
  class Type
    attr_accessor :opts
    attr_accessor :value

    def self.load name
      klass = 'Typero::%sType' % name.to_s.gsub(/[^\w]/,'').classify

      if const_defined? klass
        klass.constantize
      else
        raise ArgumentError, 'Typero type "%s" is not defined (%s)' % [name, klass]
      end
    end

    ###

    def initialize value, opts={}
      @value = value
      @opts  = opts
    end

    # default validation for any type
    def validate
      true
    end

    # get error from option or the default one
    def error_for name
      @opts[name] || send(name)
    end

    def default
      nil
    end
  end
end


