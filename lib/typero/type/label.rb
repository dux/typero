class Typero::LabelType < Typero::Type
  def set
    @value = @value.to_s.gsub(/\s+/,'-').gsub(/[^\w\-]/,'').gsub(/\-+/, '-')[0,30].downcase
  end

  def validate
    raise TypeError, unallowed_characters_error unless @value =~ /^[\w\-]+$/
  end

  def unallowed_characters_error
    'Label is having unallowed characters'
  end
end
