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
        Typero.validate(el, type) { |msg|
          raise TypeError.new "'%s' %s (value in list)" % [el, msg]
        }
      }
    end

    # this converts Sequel::Postgres::PGArray to Array and fixes many problems
    @value = @value.to_a if @value.class != Array
  end

  def validate
    raise TypeError, 'Min array lenght is %s elements' % @opts[:min] if @opts[:min] && @value.length < @opts[:min]
    raise TypeError, 'Max array lenght is %s elements' % @opts[:max] if @opts[:max] && @value.length > @opts[:max]
    true
  end
end

