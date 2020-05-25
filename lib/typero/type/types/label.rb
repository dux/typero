class Typero::LabelType < Typero::Type
  def set
    @value = @value.to_s.gsub(/\s+/,'-').gsub(/[^\w\-]/,'').gsub(/\-+/, '-')[0,30].downcase
  end

  def validate
    error_for(:unallowed_characters_error) unless @value =~ /^[\w\-]+$/
  end

  def db_field
    opts = {}
    opts[:limit]   = 30
    [:string, opts]
  end
end
