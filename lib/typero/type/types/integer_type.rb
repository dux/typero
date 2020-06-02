class Typero::IntegerType < Typero::Type
  opts :min, 'Minimum value'
  opts :max, 'Maximun value'

  def set
    value(&:to_i)

    error_for(:min_value_error, opts[:min], value) if opts[:min] && value < opts[:min]
    error_for(:max_value_error, opts[:max], value) if opts[:max] && value > opts[:max]
  end

  def db_schema
    [:integer, {}]
  end
end

