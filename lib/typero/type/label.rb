class Typero::LabelType < Typero::Type
  def set
    @value = @value.to_s.gsub(/\s+/,'-').gsub(/[^\w\-]/,'')[0,30].downcase
  end

  def validate
    raise TypeError, "Label is having unallowed characters" unless @value =~ /^[\w\-]+$/
  end
end
