# frozen_string_literal: true

module Sequel::Plugins::TyperoAttributes
  module ClassMethods
    def typero
      Typero.new self
    end
  end

  module InstanceMethods
    # calling typero! on any object will validate all fields
    def typero! field_name=nil
      return unless Typero.defined?(self.class)

      typero = self.class.typero

      typero.validate(self) do |name, err|
        errors.add(name, err) unless (errors.on(name) || []).include?(err)
      end

      # this are rules unique to database, so we check them here
      typero.rules.each do |field, rule|
        self[field] ||= {} if rule[:type] == 'hash'

        # check uniqe fields
        if rule[:unique]
          id    = self[:id] || 0
          value = self[field]

          # we only check if field is changed
          if value.present? && column_changed?(field) && self.class.xwhere('LOWER(%s)=LOWER(?) and id<>?' % field, value, id).first
            error = rule[:unique].class == TrueClass ? %[Value '"#{value}"' for #{field} allready exists] : rule[:unique]
            errors.add(field, error) unless (errors.on(field) || []).include?(error)
          end
        end

        # check protected fields
        if rule[:protected] && self[:id]
          if column_changed?(field)
            error = rule[:protected].class == TrueClass ? "value once defined can't be overwritten." : rule[:protected]
            errors.add(field, error) unless (errors.on(field) || []).include?(error)
          end
        end
      end

      # check single field if single field given
      if field_name
        raise ArgumentError.new 'Field :%s not found in %s' % [field_name, self] unless self[field_name]
        return unless errors.on(field_name)

        errors.on(field_name).join(', ')
      end

      true
    end

    def validate
      typero!
      super
    end
  end

  module DatasetMethods

  end
end

Sequel::Model.plugin :typero_attributes

