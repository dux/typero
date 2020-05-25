class Typero::HashType < Typero::Type
  error :en, :not_hash_type_error, 'value is not hash type'

  def default
    {}
  end

  def set
    @value = @value.to_h
  end

  def validate
    error_for(:not_hash_type_error) unless @value.is_a?(Hash)
  end

  def db_field
    [:jsonb, {
      null: false
    }]
  end
end

