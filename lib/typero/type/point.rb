class Typero::PointType < Typero::Type
  def set
    if @value.present?
      if @value.include?('/@')
        point = @value.split('/@', 2).last.split(',')
        @value = [point[0], point[1]].join(',')
      end

      unless @value.include?('POINT')
        point = @value.sub(/,\s*/, ' ')
        @value = 'SRID=4326;POINT(%s)' % point
      end
    end
  end

  def validate
    raise TypeError, error_for(:unallowed_characters_error) unless @value =~ /^SRID=4326;POINT\(/
  end

  def db_field
    [:geography, {}]
  end

end

