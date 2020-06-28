# frozen_string_literal: true

module Sequel::Plugins::TyperoAttributes
  module ClassMethods
    def typero
      Typero.schema self
    end
  end

  module InstanceMethods
    # calling typero! on any object will validate all fields
    def validate
      super

      schema = Typero.schema(self.class) || return

      schema.validate(self) do |name, err|
        errors.add(name, err) unless (errors.on(name) || []).include?(err)
      end

      # this are rules unique to database, so we check them here
      schema.rules.each do |field, rule|
        # check uniqe fields
        if unique = rule.dig(:meta, :unique)
          id    = self[:id] || 0
          value = self[field]

          # we only check if field is changed
          if value.present? && column_changed?(field) && self.class.xwhere('LOWER(%s)=LOWER(?) and id<>?' % field, value, id).first
            error = unique.class == TrueClass ? %[Value '"#{value}"' for #{field} allready exists] : unique
            errors.add(field, error) unless (errors.on(field) || []).include?(error)
          end
        end

        # check protected fields
        if prot = rule.dig(:meta, :protected) && self[:id]
          if column_changed?(field)
            error = prot.class == TrueClass ? "value once defined can't be overwritten." : prot
            errors.add(field, error) unless (errors.on(field) || []).include?(error)
          end
        end
      end
    end
  end

  module DatasetMethods

  end
end

Sequel::Model.plugin :typero_attributes

