class Typero::Type
  attr_accessor :opts
  attr_accessor :value

  def initialize(value, opts={})
    @value = value
    @opts  = opts
  end

  # default validation for any type
  def validate(what)
    true
  end

  def get
    @value
  end

  def set
    @value
  end

  def default
    nil
  end
end


