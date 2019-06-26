class Typero::JsonbType < Typero::Type
  def set
    @value ||= {}
  end
end

