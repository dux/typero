class Typero::UrlType < Typero::Type
  error :en, :url_not_starting_error, 'URL is not starting with http'

  def set
    @value = 'http://%s' % @value unless @value.include?('://')
  end

  def validate
    error_for(:url_not_starting_error) unless @value =~ /^https?:\/\/./
  end

  def db_field
    opts = {}
    opts[:null] = false if @opts[:required]
    [:string, opts]
  end
end

