# Posrgre geography data type
# covert google loc to field, auto fix other values

class Typero::GeographyType < Typero::Type
  def default
    false
  end

  def db_field
    [:geography]
  end
end

