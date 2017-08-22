class Typero::HashType < Typero::Type
  def default
    {}
  end

  def validate
    raise TypeError, 'Value is not hash type' unless @value.is_a?(Hash)
  end
end

