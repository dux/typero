# Same as point, but we keep data as a float in Array

class Typero::SimplePointType < Typero::Type
  def set
    if value.include?('/@')
      # extract value from google maps link
      point = value.split('/@', 2).last.split(',')[0,2]
      value { point }
    end

    if !value.include?('POINT') && value.include?(',')
      value { value.split(/\s*,\s*/)[0,2] }
    end

    # value { value.map { sprintf("%.16f", _1).to_f } }
  end

  def db_schema
    [:float, { array: true }]
  end
end

