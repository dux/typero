class Typero::IntegerType < Typero::Type
  def set
    @value = @value.to_i
  end

  def validate
    raise TypeError, 'min is %s, got %s' % [@opts[:min], @value] if @opts[:min] && @value < @opts[:min]
    raise TypeError, 'max is %s, got %s' % [@opts[:max], @value] if @opts[:max] && @value > @opts[:max]
  end
end

