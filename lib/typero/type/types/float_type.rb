class Typero::FloatType < Typero::Type
  opts :min, 'Minimum value'
  opts :max, 'Maximum value'
  opts :round, 'Round to (decimal spaces)'

  def set
    @value =
    if opts[:round]
      value.to_f.round(opts[:round])
    else
      value.to_f
    end

    error_for(:min_value_error, opts[:min], value) if opts[:min] && value < opts[:min]
    error_for(:max_value_error, opts[:max], value) if opts[:max] && value > opts[:max]
  end

  def db_schema
    [:float, {}]
  end
end

