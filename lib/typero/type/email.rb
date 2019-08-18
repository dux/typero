class Typero::EmailType < Typero::Type

  def set
    @value = @value.downcase.gsub(/\s+/,'+')
  end

  def validate
    raise TypeError, error_for(:not_8_chars_error) unless @value.to_s.length > 7
    raise TypeError, error_for(:missing_monkey_error) unless @value.include?('@')
  end

  def not_8_chars_error
    'is not having at least 8 characters'
  end

  def missing_monkey_error
    'is missing @'
  end

  def db_field
    opts = {}
    opts[:limit] = @opts[:max] || 120
    opts[:null]  = false if @opts[:required]
    [:string, opts]
  end
end

