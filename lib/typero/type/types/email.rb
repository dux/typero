class Typero::EmailType < Typero::Type
  error :en, :not_8_chars_error, 'is not having at least 8 characters'
  error :en, :missing_monkey_error, 'is missing @'

  def set
    @value = @value.downcase.gsub(/\s+/,'+')
  end

  def validate
    error_for(:not_8_chars_error) unless @value.to_s.length > 7
    error_for(:missing_monkey_error) unless @value.include?('@')
  end

  def db_field
    opts = {}
    opts[:limit] = @opts[:max] || 120
    opts[:null]  = false if @opts[:required]
    [:string, opts]
  end
end

