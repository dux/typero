module Typero
  class EmailType < Typero::Type
    def set(value)
      value.downcase
    end

    def validate(value)
      raise TypeError, 'not having at least 8 characters' unless value.to_s.length > 7
      raise TypeError, 'missing @' unless value.include?('@')
      raise TypeError, 'in wrong domain' unless value =~ /\.\w{2,4}$/
      raise TypeError, 'in wrong format' unless value =~ /^[\w\-\.]+\@[\w\-\.]+$/i
      true
    end
  end
end

