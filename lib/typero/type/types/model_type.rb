class Typero::ModelType < Typero::Type
  def set
    value(&:to_h)

    errors = []

    schema = Typero.schema(opts[:model])
    schema.validate(value) do |field, error|
      errors.push '%s (%s)' % [error, field]
    end

    raise TypeError.new errors.join(', ') if errors.first
  end

  def db_schema
    [:jsonb, {
      null: false
    }]
  end
end

