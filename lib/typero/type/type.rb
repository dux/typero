# Master class

module Typero
  class Type
    ERRORS = {
      en: {
        # errors shared between various types
        min_length_error: 'min lenght is %s, you have %s',
        max_length_error: 'max lenght is %s, you have %s',
        min_value_error: 'min is %s, got %s',
        max_value_error: 'max is %s, got %s',
        unallowed_characters_error: 'is having unallowed characters'
      }
    }

    OPTS = {}

    attr_accessor :opts
    attr_accessor :value

    class << self
      def load name
        klass = 'Typero::%sType' % name.to_s.gsub(/[^\w]/,'').classify

        if const_defined? klass
          klass.constantize
        else
          raise ArgumentError, 'Typero type "%s" is not defined (%s)' % [name, klass]
        end
      end

      def error locale, key, message
        locale = locale.to_sym
        ERRORS[locale] ||= {}
        ERRORS[locale][key.to_sym] = message
      end

      def opts key, desc
        OPTS[self] ||= {}
        OPTS[self][key] = desc
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

    def default
      nil
    end

    private

    # get error from option or the default one
    def error_for name, *args
      locale =
      if defined?(Lux)
        Lux.current.locale.to_s
      elsif defined?(I18n)
        I18n.locale
      end

      locale  = :en if locale.to_s == ''
      pointer = ERRORS[locale.to_sym] || ERRORS[:en]
      error   = @opts.dig(:meta, locale, name) || @opts.dig(:meta, name) || pointer[name]
      error   = error % args if args.first

      raise 'Type error :%s not defined' % name unless error
      raise TypeError.new(error)
    end
  end
end


