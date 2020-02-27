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
  attr_accessor :url

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

Typero.new :test do
  string   :name
  float    :speed, min:10, max:200
  email    :email, req: true
  email    :email_nil
  email    [:emails]
  label    [:tags]
  string   :eyes, default:'blue'
  set      :age, Integer, req: true
  date     :date
  datetime :datetime
  date     :point
  datetime :url
end

Typero.new model: TestFoo do
  string  :name
end

Typero.new model: 'TestBar' do
  string  :name
end
