class Typero::BooleanType < Typero::Type
  def default
    false
  end

  def set
    @value = [true, 1, '1', 'true', 'on'].include?(@value) ? true : false
  end
end

