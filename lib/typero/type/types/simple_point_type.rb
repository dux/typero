# Same as point, but we keep data as a float array [lat, lon]

class Typero::SimplePointType < Typero::Type
  include Typero::GeoExtract

  def coerce
    coords = extract_coords(value)

    if coords
      value { coords }
    else
      error_for(:unallowed_characters_error)
    end
  end

  def db_schema
    [:float, { array: true }]
  end
end
