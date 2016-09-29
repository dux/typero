module Typero
  class EmailType < Typero::Type
    def set(value)
      value.downcase
    end

    def validate(value)
      raise TypeError, 'is not having at least 8 characters' unless value.to_s.length > 7
      raise TypeError, 'is missing @' unless value.include?('@')
      raise TypeError, 'is in wrong domain' unless value =~ /\.\w{2,4}$/
      raise TypeError, 'is in wrong format' unless value =~ /^[\w\-\.]+\@[\w\-\.]+$/i
      true
    end
  end
end

