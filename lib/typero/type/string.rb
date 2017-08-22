class Typero::StringType < Typero::Type
  def set
    @value = @value.to_s unless @value.is_a?(String)
    @value = @value.downcase if @opts[:downcase]
  end

  def validate
    raise TypeError, 'min lenght is %s, you have %s' % [@opts[:min], @value.length] if @opts[:min] && @value.length < @opts[:min]
    raise TypeError, 'max lenght is %s, you have %s' % [@opts[:max], @value.length] if @opts[:max] && @value.length > @opts[:max]
  end
end

