class Typero::IntegerType < Typero::Type
  def set
    @value = @value.to_i
  end

  def validate
    raise TypeError, min_error % [@opts[:min], @value] if @opts[:min] && @value < @opts[:min]
    raise TypeError, max_error % [@opts[:max], @value] if @opts[:max] && @value > @opts[:max]
  end

  def min_error
    'min is %s, got %s'
  end

  def max_error
    'max is %s, got %s'
  end
end

