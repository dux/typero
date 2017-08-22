class Typero::UrlType < Typero::Type
  def set
    @value = 'http://%s' % @value unless @value.include?('://')
  end

  def validate
    raise TypeError, 'URL is not starting with http' unless @value =~ /^https?:\/\/./
  end
end

