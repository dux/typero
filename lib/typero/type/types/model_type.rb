class Typero::ModelType < Typero::Type
  def set
    value(&:to_h)

    errors = {}
    schema = opts[:model].is_a?(Typero::Schema) ? opts[:model] : Typero.schema(opts[:model])

    # by default models in schems are strict true (remove undefined keys)
    schema.validate value, strict: true do |field, error|
      errors[field] = error
    end

    @value.delete_if {|_, v| v.empty? }

    raise TypeError.new errors.to_json if errors.keys.first
  end

  def db_schema
    [:jsonb, {
      null: false
    }]
  end
end

