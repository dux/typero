class Typero::UrlType < Typero::Type
  def set
    @value = 'http://%s' % @value unless @value.include?('://')
  end

  def validate
    raise TypeError, error_for(:not_starting_error) unless @value =~ /^https?:\/\/./
  end

  def not_starting_error
    'URL is not starting with http'
  end

  def db_field
    opts = {}
    opts[:null] = false if @opts[:req]
    [:string, opts]
  end
end

