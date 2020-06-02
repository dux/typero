require_relative 'date_type'

class Typero::DatetimeType < Typero::DateType
  def set
    value { |data| DateTime.parse(data) }

    check_date_min_max
  end

  def db_schema
    [:datetime]
  end
end

