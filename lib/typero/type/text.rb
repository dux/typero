require_relative 'string'

class Typero::TextType < Typero::StringType
  def db_field
    opts = {}
    opts[:null]  = false if @opts[:required]
    [:text, opts]
  end
end