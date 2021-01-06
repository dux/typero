class Typero::HashType < Typero::Type
  error :en, :not_hash_type_error, 'value is not hash type'

  def set
    if value.is_a?(String) && value[0,1] == '{'
      @value = JSON.load(value)
    end

    @value ||= {}

    error_for(:not_hash_type_error) unless @value.respond_to?(:keys) && @value.respond_to?(:values)

    if opts[:allow]
      for key in @value.keys
        @value.delete(key) unless opts[:allow].include?(key)
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

