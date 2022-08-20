# for postgres - select st_asewkt(lon_lat) || st_astext(lon_lat)
# point = @object.class.xselect("ST_AsText(#{field}) as #{field}").where(id: @object.id).first[field.to_sym]

class Typero::PointType < Typero::Type
  def set
    if value.include?('/@')
      # extract value from google maps link
      point = value.split('/@', 2).last.split(',')
      value { [point[0], point[1]].join(',') }
    end

    if !value.include?('POINT') && value.include?(',')
      point = value.sub(/\s*,\s*/, ' ')
      value { 'SRID=4326;POINT(%s)' % point }
    end

    if value && value.include?(',') && !value =~ /^SRID=4326;POINT\(/
      error_for(:unallowed_characters_error)
    end
  end

  def db_schema
    [:geography, {}]
  end
end

