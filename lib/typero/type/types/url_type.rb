class Typero::UrlType < Typero::Type
  error :en, :url_not_starting_error, 'URL is not starting with http or https'

  def set
    parts = value.split('://')
    error_for(:url_not_starting_error) unless parts[1]
  end

  def db_schema
    [:string, {}]
  end
end

