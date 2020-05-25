require_relative 'string'

class Typero::TextType < Typero::StringType
  opts :min, 'Minimun string length'
  opts :max, 'Maximun string length'

  def db_field
    opts = {}
    opts[:null]  = false if @opts[:required]
    [:text, opts]
  end
end