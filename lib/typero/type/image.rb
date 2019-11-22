class Typero::ImageType < Typero::Type
  # FORMATS = %w[jpg jpeg gif png svg]

  def set
    @value = 'https://%s' % @value unless @value.include?('://')
  end

  def validate
    raise TypeError, error_for(:not_starting_error) unless @value =~ /^https?:\/\/./
    # ext = @value.split('.').last.downcase
    # raise TypeError, error_for(:not_image_format) unless FORMATS.include?(ext)
  end

  def not_starting_error
    'URL is not starting with http'
  end

  # def not_image_format
  #   'URL is not ending with %s' % FORMATS.join(', ')
  # end

  def db_field
    opts = {}
    opts[:null] = false if @opts[:required]
    [:string, opts]
  end
end

