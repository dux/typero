# you should not use this filed for currency calculations
# use integer and covert in code
# Example: use cents and divide by 100 for $

require_relative './float_type'

class Typero::CurrencyType < Typero::FloatType

  def set
    value { |data| data.to_f.round(2) }
  end

  def db_schema
    [:decimal, {
      precision: 8,
      scale:     2
    }]
  end

end

