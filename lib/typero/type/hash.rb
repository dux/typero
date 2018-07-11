class Typero::HashType < Typero::Type
  def default
    {}
  end

  def validate
    raise TypeError, error_for(:not_hash_type_error) unless @value.is_a?(Hash)
  end

  def not_hash_type_error
    'value is not hash type'
  end
end

