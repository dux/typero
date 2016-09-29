module Typero
  class LabelType < Typero::Type
    def set(value)
      value.to_s.gsub(/[^\w\-]/,'')[0,30].downcase
    end

    def validate(value)
      raise TypeError, "Label is having unallowed characters" unless value =~ /^[\w\-]+$/
      true
    end
  end
end

