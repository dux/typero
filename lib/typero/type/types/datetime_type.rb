require_relative 'date_type'

class Typero::DatetimeType < Typero::DateType
  opts :min, 'Smallest date allowed'
  opts :max, 'Maximal date allowed'

  def set
    unless [Time, DateTime].include?(value.class)
      value { |data| DateTime.parse(data) }
    end

    check_date_min_max
  end

  def db_schema
    [:datetime]
  end
end

