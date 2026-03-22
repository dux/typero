# for postgres - select st_asewkt(lon_lat) || st_astext(lon_lat)
# point = @object.class.xselect("ST_AsText(#{field}) as #{field}").where(id: @object.id).first[field.to_sym]

class Typero::PointType < Typero::Type
  include Typero::GeoExtract

  def coerce
    if value.is_a?(String) && !value.include?('POINT')
      coords = extract_coords(value)

      if coords
        value { 'SRID=4326;POINT(%s %s)' % [coords[0], coords[1]] }
      else
        error_for(:unallowed_characters_error)
      end
    end
  end

  def db_schema
    [:geography, {}]
  end
end
