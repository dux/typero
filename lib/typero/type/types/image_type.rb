class Typero::ImageType < Typero::Type
  FORMATS = %w[jpg jpeg gif png svg webp]

  error :en, :image_not_starting_error, 'URL is not starting with http'
  error :en, :image_not_image_format, 'URL is not ending with %s' % FORMATS.join(', ')

  opts :strict, 'Force image to have known extension (%s)' % FORMATS.join(', ')

  def set
    error_for(:image_not_starting_error) unless value =~ /^https?:\/\/./

    if opts[:strict]
      ext = value.split('.').last.downcase
      error_for(:image_not_image_format) unless FORMATS.include?(ext)
    end
  end

  def db_schema
    [:string]
  end
end

