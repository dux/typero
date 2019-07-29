class Typero::TextType < Typero::StringType
  def db_field
    opts = {}
    opts[:null]  = false if @opts[:req]
    [:text, opts]
  end
end