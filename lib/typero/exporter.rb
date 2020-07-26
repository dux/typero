module Typero
  class Exporter
    EXPORTERS ||= {}

    attr_accessor :response

    def initialize model, opts={}
      opts = { user: opts } unless opts.is_a?(Hash)

      opts[:exporter]      ||= model.class
      opts[:depth]         ||= 1
      opts[:current_depth] ||= 0

      exporter = opts.delete(:exporter).to_s.classify

      @model        = model
      @opts         = opts
      @block        = EXPORTERS[exporter] || raise('Exporter "%s" (:%s) not found' % [exporter, exporter.to_s.underscore])
      @after_filter = EXPORTERS[:after_filter]
      @response     = {}
    end

    def render
      instance_exec &@block
      instance_exec &@after_filter if @after_filter
      @response
    end

    private

    def export object, opts={}
      case object
      when Symbol
        return property object, export(model.send(object))
      when Array
        return object.map { |o| export(o) }
      end

      return if @opts[:current_depth] >= @opts[:depth]

      @opts[:current_depth] += 1
      out = self.class.new(object, @opts.merge(opts)).render
      @opts[:current_depth] -= 1
      out
    end

    def property name, data=:_undefined
      if block_given?
        data = yield if data == :_undefined
        @response[name] = data unless data.nil?
      else
        data = data == :_undefined ? model.send(name) : data

        if data
          if data.respond_to?(:export_json)
            data = data.export_json
          elsif data.is_a?(Array)
          elsif data.respond_to?(:to_h)
            data = data.to_h
          end
        end

        @response[name] = data unless data.nil?
      end
    end
    alias :prop :property

    def hproperty name
      @response[name] = model[name]
    end
    alias :hprop :hproperty

    def namespace name, &block

    end

    def meta &block
      namespace :meta, &block
    end

    def model
      @model
    end

    # get current user from globals if globals defined
    def user
      if @opts[:user]
        @opts[:user]
      elsif defined?(User) && User.respond_to?(:current)
        User.current
      elsif defined?(Current) && Current.respond_to?(:user)
        Current.user
      elsif current_user = Thread.current[:current_user]
        current_user
      else
        nil
      end
    end
  end
end

