module Typero
  class StringType < Typero::Type
    def set(value)
      value = value.to_s
      value = value.downcase if @opts[:downcase]
      value
    end
  end
end

