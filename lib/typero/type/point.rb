# for postgres - select st_asewkt(lon_lat) || st_astext(lon_lat)
# point = @object.class.xselect("ST_AsText(#{field}) as #{field}").where(id: @object.id).first[field.to_sym]

class Typero::PointType < Typero::Type
  def set
    ap @value
    if @value.present?
      if @value.include?('/@')
        point = @value.split('/@', 2).last.split(',')
        @value = [point[0], point[1]].join(',')
      end

      if !@value.include?('POINT') && @value.include?(',')
        point = @value.sub(/,\s*/, ' ')
        @value = 'SRID=4326;POINT(%s)' % point
      end
    end
  end

  def validate
    if @value && @value.include?(',') && !@value =~ /^SRID=4326;POINT\(/
      raise TypeError, error_for(:unallowed_characters_error)
    end
  end

  def db_field
    [:geography, {}]
  end

end

