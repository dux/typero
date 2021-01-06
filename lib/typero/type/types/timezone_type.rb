class Typero::TimezoneType < Typero::Type
  error :en, :invalid_time_zone, 'Invalid time zone'

  def set
    TZInfo::Timezone.get(value)
  rescue TZInfo::InvalidTimezoneIdentifier
    error_for :invalid_time_zone
  end

  def db_schema
    [:string, { length: 50 }]
  end

end

