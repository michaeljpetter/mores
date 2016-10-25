module Mores

  module Chainable
    def self.included(mod)
      mod.extend ClassMethods
    end

    def **(chain)
      @__chain = chain
      self
    end

    private

    def __chain
      @__chain ||= self.class.__send__(:__default_chain).new
    end

    module ClassMethods
      def chain(name, &block)
        __forwarder.__send__(:define_method, name) do |*args|
          __chain.public_send(name, *args)
        end
        __default_chain.__send__(:define_method, name, block || proc { |*| })
      end

      private

      def __forwarder
        @__forwarder ||= superclass < Chainable ? superclass.__send__(:__forwarder) : Module.new.tap { |m| include m }
      end

      def __default_chain
        @__default_chain ||= Class.new(superclass < Chainable ? superclass.__send__(:__default_chain) : Object)
      end
    end
  end

end
