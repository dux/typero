class Typero::LabelType < Typero::Type
  def set
    @value = @value.to_s.gsub(/\s+/,'-').gsub(/[^\w\-]/,'').gsub(/\-+/, '-')[0,30].downcase
  end

  def validate
    raise TypeError, error_for(:unallowed_characters_error) unless @value =~ /^[\w\-]+$/
  end

  def unallowed_characters_error
    'label is having unallowed characters'
  end

  def db_field
    opts = {}
    opts[:limit]   = 30
    [:string, opts]
  end
end
