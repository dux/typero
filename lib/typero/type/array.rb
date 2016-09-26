module Typero
  class ArrayType < Typero::Type
    def default
      []
    end

    def set(value)
      value = value.to_s.split(/\s*,\s*/) unless value.class.to_s.index('Array')
      if type = @opts[:array_type]
        check_type(type)
        value.each { |el| Typero.validate!(el, type) }
      end
      value
    end

    def min(value, length)
      raise TypeError, "Min array lenght is #{length} elements" if value.length  < length
    end

    def max(value, length)
      raise TypeError, "Max array lenght is #{length} elements" if value.length  > length
    end
  end
end

