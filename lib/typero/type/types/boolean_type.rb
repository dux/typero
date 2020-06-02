class Typero::BooleanType < Typero::Type
  error :en, :unsupported_boolean, 'Unsupported boolean param value: %s'

  def set
    value do |_|
      bool = _.to_s

      if value == ''
        false
      elsif %w(true 1 on).include?(bool)
        true
      elsif %w(false 0 off).include?(bool)
        false
      else
        error_for :unsupported_boolean, bool
      end
    end
  end

  def db_schema
    [:boolean, {
      default: opts[:default] || false
    }]
  end
end

