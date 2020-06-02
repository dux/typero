class Typero::HashType < Typero::Type
  error :en, :not_hash_type_error, 'value is not hash type'

  def set
    error_for(:not_hash_type_error) unless value.is_a?(Hash)

    if opts[:allow]
      for key in value.keys
        value.delete(key) unless opts[:allow].include?(key)
      end
    end
  end

  def default
    {}
  end

  def db_schema
    [:jsonb, {
      null: false,
      default: '{}'
    }]
  end
end
