class Typero::StringType < Typero::Type
  opts :min, 'Minimun string length'
  opts :max, 'Maximun string length'
  opts :downcase, 'is the string in downcase?'

  def set
    value(&:to_s)
    value(&:downcase) if opts[:downcase]

    error_for(:min_length_error, opts[:min], value.length) if opts[:min] && value.length < opts[:min]
    error_for(:max_length_error, opts[:max], value.length) if opts[:max] && value.length > opts[:max]
  end

  def db_schema
    [:string, {
      limit: @opts[:max] || 255
    }]
  end
end

