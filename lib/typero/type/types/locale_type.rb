class Typero::LocaleType < Typero::Type
  error :en, :locale_bad_format, 'Locale "%s" is in bad format (should be xx or xx-xx)'

  def set
    error_for(:locale_bad_format, value) unless value =~ /^[\w\-]{2,5}$/
  end

  def db_schema
    [:string, { limit: 5 }]
  end
end


