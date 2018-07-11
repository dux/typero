class Typero::StringType < Typero::Type
  def set
    @value = @value.to_s unless @value.is_a?(String)
    @value = @value.downcase if @opts[:downcase]
  end

  def validate
    raise TypeError, error_for(:min_length_error) % [@opts[:min], @value.length] if @opts[:min] && @value.length < @opts[:min]
    raise TypeError, error_for(:max_length_error) % [@opts[:max], @value.length] if @opts[:max] && @value.length > @opts[:max]
  end

  # ready for localization

  def min_length_error
    'min lenght is %s, you have %s'
  end

  def max_length_error
    'max lenght is %s, you have %s'
  end
end

