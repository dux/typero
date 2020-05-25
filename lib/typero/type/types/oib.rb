class Typero::OibType < Typero::Type
  error :en, :not_an_oib_error, 'not in an OIB format'

  def set
    @value = check?(@value) ? @value.to_i : nil
  end

  def validate
    error_for(:not_an_oib_error) unless check?(@value)
  end

  def db_field
    opts = {}
    opts[:null]  = false if @opts[:required]
    opts[:limit] = 11
    [:string, opts]
  end

  private

  # http://domagoj.eu/oib/
  def check? oib
    oib = oib.to_s

    return false unless oib.match(/^[0-9]{11}$/)

    control_sum = (0..9).inject(10) do |middle, position|
      middle += oib.at(position).to_i
      middle %= 10
      middle = 10 if middle == 0
      middle *= 2
      middle %= 11
    end

    control_sum = 11 - control_sum
    control_sum = 0 if control_sum == 10

    return control_sum == oib.at(10).to_i
  end

end

