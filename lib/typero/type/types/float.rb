class Typero::FloatType < Typero::Type
  opts :min, 'Minimum value'
  opts :max, 'Maximun value'

  def set
    @value = @value.to_f
  end

  def validate
    error_for(:min_length_error, @opts[:min], @value) if @opts[:min] && value < @opts[:min]
    error_for(:max_length_error, @opts[:max], @value) if @opts[:max] && value > @opts[:max]
  end

  def db_field
    opts = {}
    opts[:null] = false if @opts[:required]
    [:float, opts]
  end

end

