class Typero::ModelType < Typero::Type
  def set
    value(&:to_h)

    errors = {}

    schema = opts[:model].is_a?(Typero::Schema) ? opts[:model] : Typero.schema(opts[:model])
    schema.validate(value) do |field, error|
      errors[field] = error
    end

    raise TypeError.new errors.to_json if errors.keys.first
  end

  def db_schema
    [:jsonb, {
      null: false
    }]
  end
end

