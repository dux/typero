class Typero::FloatType < Typero::Type

  def set
    @value = @value.to_f
  end

  def validate
    raise TypeError, error_for(:min_length_error) % @opts[:min] if @opts[:min] && value < @opts[:min]
    raise TypeError, error_for(:max_length_error) % @opts[:max] if @opts[:max] && value > @opts[:max]
  end

  def min_length_error
    "min lenght is %s"
  end

  def max_length_error
    "max lenght is %s"
  end

  def db_field
    opts = {}
    opts[:null] = false if @opts[:required]
    [:float, opts]
  end

end

