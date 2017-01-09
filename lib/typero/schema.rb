# validates hash against the schema
# good if you can create validate objects and check against for function parameters
# use whenever you want to check hash values of variables
# in Lux FW, used in api cell

# Typero::Schema.load_schema(email:{ req: true, type: :email}, age: { type: Integer, req: false })
module Typero
  class Schema
    class << self
      # loads schema from hash and creates schema object
      def load_schema(hash)
        validate = new
        for k,v in hash
          validate.set(k,v)
        end
        validate
      end
    end

    ###

    def initialize
      @check = {}
    end

    # set field values to check
    # :age, Integer, { min:18, max:110 }
    # :email, :email, { req:false }
    def set(field, opts={}, &block)
      opts[:req] ||= true unless opts[:req].class == FalseClass
      opts[:func] = block if block_given?
      opts[:type] ||= String
      @check[field] = opts
    end

    # check agains hash of values { email:'dux@net.hr', age:'40' }
    def check(hash)
      errors = {}
      for field in @check.keys
        value = hash[field]
        check_hash = @check[field]
        type = check_hash[:type]

        if value.blank? && check_hash[:req].class != FalseClass
          errors[field] = check_hash[:req].kind_of?(String) ? check_hash[:req] : "#{field.to_s.capitalize} is required"
          next
        end

        if check_hash[:func]
          begin
            check_hash[:func].call(value.to_s)
          rescue
            errors[field] = $!.message
          end
        else
          Typero.validate!(value, type, check_hash) { |msg|
            errors[field] = "#{field.to_s.capitalize}: #{msg}"
          }

          # coerce value
          hash[field] = Typero.quick_set(value, type) if value.present?
        end
      end
      errors.keys.length > 0  ? errors : nil
    end

    def keys
      @check.keys
    end
  end
end
