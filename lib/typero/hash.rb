module Typero

  # adds hash interface to models
  module Hash
    def [](k)
      @attrs ||= {}
      @attrs[k]
    end

    def []=(k,v)
      @attrs ||= {}
      @attrs[k] = v
    end
  end

end