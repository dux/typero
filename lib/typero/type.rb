class Typero::Type
  attr_accessor :opts
  attr_accessor :value

  def self.load name
    klass = 'Typero::%sType' % name.to_s.gsub(/[^\w]/,'').classify
    klass.constantize
  end

  ###

  def initialize(value, opts={})
    @value = value
    @opts  = opts
  end

  # default validation for any type
  def validate(what)
    true
  end

  def error_for name
    @opts[name] || send(name)
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


