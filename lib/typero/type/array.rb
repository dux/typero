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

    def validate(list)
      raise TypeError, "Min array lenght is #{@opts[:min]} elements" if @opts[:min] && @opts[:min] < list.length
      raise TypeError, "Max array lenght is #{@opts[:max]} elements" if @opts[:max] && @opts[:max] < list.length
      true
    end
  end
end

