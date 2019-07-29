require_relative './float'

class Typero::CurrencyType < Typero::FloatType

  def set
    @value = @value.to_f.round(2)
  end

  def db_field
    opts = {}
    opts[:precision] = 8
    opts[:scale]     = 2
    [:decimal, opts]
  end

end

