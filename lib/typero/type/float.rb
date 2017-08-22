class Typero::FloatType < Typero::Type

  def set
    @value = @value.to_f
  end

  def validate
    raise TypeError, "min lenght is #{@opts[:min]}" if @opts[:min] && value < @opts[:min]
    raise TypeError, "max lenght is #{@opts[:max]}" if @opts[:max] && value > @opts[:max]
  end

end

