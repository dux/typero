module Typero
  class BooleanType < Typero::Type
    def default
      false
    end

    def set(value)
      [true, 1, '1', 'true'].index(value) ? true : false
    end
  end
end

