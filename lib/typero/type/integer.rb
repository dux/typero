module Typero
  class IntegerType < Typero::Type
    def set(value)
      value.to_i
    end

    def validate(input)
      value = set(input)

      raise TypeError, "min lenght is #{@opts[:min]}, you have #{value}" if @opts[:min] && value < @opts[:min]
      raise TypeError, "max lenght is #{@opts[:max]}, you have #{value}" if @opts[:max] && value > @opts[:max]

      true
    end
  end
end

