class Typero::DateType < Typero::Type
  def set
    @value = @value.to_s.downcase.gsub(/[^\d\-\.\s]/, '')
  end

  def db_field
    [:date, {}]
  end
end

