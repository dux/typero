require_relative 'string_type'

class Typero::TextType < Typero::StringType
  opts :min, 'Minimun string length'
  opts :max, 'Maximun string length'

  def db_schema
    [:text, {}]
  end
end