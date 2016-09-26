module Typero
  class FloatType < Typero::Type
    def set(value)
      value.to_f
    end

    def min(value, length)
      raise TypeError, "Min #{@type} lenght for #{@name} is #{length}, you have #{value}" if value.to_f  < length
    end

    def max(value, length)
      raise TypeError, "Max #{@type} length for #{@name} is #{length}, you have #{value}" if value.to_f  > length
    end
  end
end

