module Typero
  class BooleanType < Typero::Type
    def default
      false
    end

    def set(value)
      value = false if [0, '0', 'false'].index(value)
      !!value
    end
  end
end

