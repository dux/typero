module Typero
  class IntegerType < Typero::Type
    def set(value)
      value.to_i
    end
  end
end

