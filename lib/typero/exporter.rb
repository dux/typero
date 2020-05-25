module Typero
  class Exporter
    def initialize model, user=nil

    end

    def property name

    end
    alias :prop :property

    def hproperty name

    end
    alias :hprop :hproperty

    def namespace name, &block

    end

    def meta &block
      namespace :meta, &block
    end

    def user

    end

  end
end

