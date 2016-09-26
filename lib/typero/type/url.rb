module Typero
  class UrlType < Typero::Type
    def validate(value)
      raise TypeError, 'not starting with http' unless value =~ /^https?:\/\/./
      true
    end
  end
end

