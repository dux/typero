class Typero::IntegerType < Typero::Type
  def set
    @value = @value.to_i
  end

  def validate
    raise TypeError, error_for(:min_value_error) % [@opts[:min], @value] if @opts[:min] && @value < @opts[:min]
    raise TypeError, error_for(:max_value_error) % [@opts[:max], @value] if @opts[:max] && @value > @opts[:max]
  end

  def min_value_error
    'min is %s, got %s'
  end

  def max_value_error
    'max is %s, got %s'
  end
end

