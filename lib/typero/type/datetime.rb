class Typero::DatetimeType < Typero::Type
  def set
    @value = @value.to_s.downcase.gsub(/[^\d\-\.\s\:]/, '')
  end
end

