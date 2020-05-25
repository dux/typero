class Typero::IntegerType < Typero::Type
  opts :min, 'Minimum value'
  opts :max, 'Maximun value'

  def set
    @value = @value.to_i
  end

  def validate
    error_for(:min_value_error, @opts[:min], @value) if @opts[:min] && @value < @opts[:min]
    error_for(:max_value_error, @opts[:max], @value) if @opts[:max] && @value > @opts[:max]
  end

  def db_field
    opts = {}
    opts[:null]    = false if @opts[:required]
    opts[:default] = @opts[:default]
    [:integer, opts]
  end
end

