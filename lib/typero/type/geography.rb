# Posrgre geography data type
# covert google loc to field, auto fix other values

class Typero::GeographyType < Typero::Type
  def default
    false
  end

  def set
    @value = [true, 1, '1', 'true', 'on'].include?(@value) ? true : false
  end
end

