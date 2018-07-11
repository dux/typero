class Typero::ArrayType < Typero::Type
  def default
    []
  end

  def set
    unless @value.class.to_s.index('Array')
      @value = @value.to_s.sub(/^\{/,'').sub(/\}$/,'').split(/\s*,\s*/)
    end

    @value.uniq!
    @value.compact!

    if type = @opts[:array_type]
      @value.map! { |el|
        Typero.validate(type, el) { |msg|
          raise TypeError.new "'%s' %s (%s)" % [el, msg, value_in_list_error]
        }
      }
    end

    # this converts Sequel::Postgres::PGArray to Array and fixes many problems
    @value = @value.to_a if @value.class != Array
  end

  def validate
    raise TypeError, error_for(:min_length) % @opts[:min] if @opts[:min] && @value.length < @opts[:min]
    raise TypeError, error_for(:max_length) % @opts[:max] if @opts[:max] && @value.length > @opts[:max]
    true
  end

  def min_error
    'min array lenght is %s elements'
  end

  def max_error
    'max array lenght is %s elements'
  end

  def value_in_list_error
    'value in list'
  end
end

