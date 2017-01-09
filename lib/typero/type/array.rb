module Typero
  class ArrayType < Typero::Type
    def default
      []
    end

    def get(value)
      unless value.class.to_s.index('Array')
        value = value.to_s.sub(/^\{/,'').sub(/\}$/,'').split(/\s*,\s*/)
      end
      value
    end

    def set(value)
      value = get(value)
      # value = value.to_a unless value.is_array?

      # force type for all elements of array
      if type = @opts[:array_type]
        value.map! { |el|
          Typero.validate!(el, type)
          Typero.quick_set(el, type)
        }
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

