class Typero::OibType < Typero::Type
  def check? oib
    oib = oib.to_s

    return false if (oib =~ /\d{11}/) != 0
    return false if oib.length != 11

    a = 10
    (0..9).each do |i|
      a = (a + oib[i,1].to_i) % 10
      a = 10 if a == 0
      a = (a * 2) % 11
    end

    kontrolna = 11 - a
    kontrolna = 0 if kontrolna == 10

    kontrolna == oib[10,1].to_i
  end

  def set
    @value = check?(@value) ? @value.to_i : nil
  end

  def validate
    raise TypeError.new('Not an OIB') unless check?(@value)
  end
end

