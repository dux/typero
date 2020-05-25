class Typero::StringType < Typero::Type
  opts :min, 'Minimun string length'
  opts :max, 'Maximun string length'

  def set
    @value = @value.to_s unless @value.is_a?(String)
    @value = @value.downcase if @opts[:downcase]
  end

  def validate
    error_for(:min_length_error, @opts[:min], @value.length) if @opts[:min] && @value.length < @opts[:min]
    error_for(:max_length_error, @opts[:max], @value.length) if @opts[:max] && @value.length > @opts[:max]
  end

  def db_field
    opts = {}
    opts[:limit]   = @opts[:max] || 255
    opts[:null]    = false if @opts[:required]
    opts[:default] = @opts[:default]
    [:string, opts]
  end
end

