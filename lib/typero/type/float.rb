class Typero::FloatType < Typero::Type

  def set
    @value = @value.to_f
  end

  def validate
    raise TypeError, min_length_error if @opts[:min] && value < @opts[:min]
    raise TypeError, max_length_error if @opts[:max] && value > @opts[:max]
  end

  def min_length_error
    "min lenght is #{@opts[:min]}"
  end

  def max_length_error
    "max lenght is #{@opts[:max]}"
  end

end

