class Typero::UtfLabelType < Typero::Type
  MASK = /[\/\\\[\]'"]/

  def set
    @value = @value.to_s.gsub(/\s+/,'-').gsub(MASK,'')[0,50].downcase
  end

  def validate
    raise TypeError, "Label is having unallowed characters" if @value =~ MASK
  end
end
