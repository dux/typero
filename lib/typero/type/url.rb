class Typero::UrlType < Typero::Type
  def set
    @value = 'http://%s' % @value unless @value.include?('://')
  end

  def validate
    raise TypeError, not_starting_error unless @value =~ /^https?:\/\/./
  end

  def not_starting_error
    'URL is not starting with http'
  end
end

