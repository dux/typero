module Typero
  module Instance
    def self.included(base)
      def base.attribute(name, *args)
        if !args[0]
          opts = { type: :string }
        elsif args[0].class.to_s == 'Hash'
          if args[0].keys.length == 0
            opts = { type: :hash }
          else
            type = args[0][:type] || :string
            opts = args[0].merge( type: type )
          end
        elsif args[1]
          opts = args[1]
          opts[:type] = args[0]
        else
          opts = { type: args[0] }
        end

        if opts[:type].class.to_s == 'Array' && opts[:type][0] # Array[:email] -> array of emails
          opts[:array_type] = opts[:type][0].to_s.downcase.to_sym
          opts[:type] = :array
        end

        opts[:type]  = opts[:type].to_s.downcase.to_sym
        opts[:type]  = :array if opts[:type] == :[]
        opts[:req]   = "#{name.to_s.humanize.capitalize} is required" if opts[:req].class == TrueClass

        Typero.define_instance(self, name, opts)
      end
    end

    # def attributes=(opts)
    #   for k,v in opts
    #     send("#{k}=", v)
    #   end
    # end

    def attribute_errors
      # hash = InstanceAttributes.opts[self.class.to_s]
      klass = self.class.to_s
      opts = Typero.opts[klass]
      return [] unless opts
      errors = []
      for k, v in opts
        errors.push [k, v.opts[:req]] if v.opts[:req] && !v.present?(self[k])
      end
      errors
    end
  end
end
