class Test
  attr_accessor :name
  attr_accessor :speed
  attr_accessor :email
  attr_accessor :email_nil
  attr_accessor :emails
  attr_accessor :tags
  attr_accessor :eyes
  attr_accessor :age
  attr_accessor :date
  attr_accessor :datetime
  attr_accessor :point
  attr_accessor :http_loc

  def [] key
    send key
  end

  def []= key, value
    send '%s=' % key, value
  end
end

class TestFoo
  attr_accessor :name
end

TestSchema = Typero.new do
  name?       # String
  speed?      :float, min:10, max:200
  email       :email
  email_nil?  :email
  emails?     Array[:email]
  tags        Array[:label]
  eyes        default: 'blue'
  set         :age, Integer
  date        :date
  datetime    :datetime
  point       :point
  http_loc    :url

  db :timestamps
end

TestFooSchema = Typero.new do
  name # String
end
