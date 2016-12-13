require 'forwardable'

module Mores

  class Succession
    extend Forwardable
    extend BlockInitialize

    def line(name, &default)
      singleton_class.delegate name => :'__list.head.value'
      __list.tail.value.define_singleton_method name, default || proc { |*| }
    end

    def >>(value)
      value.extend __forwarder
      node = (__list.tail < value).prev
      value.define_singleton_method(:__node) { node }
      self
    end

    private

    def __list
      @__list ||= LinkedList.new >> Object.new
    end

    def __forwarder
      @__forwarder ||= Module.new.module_exec(self) do |succession|
        define_method(:method_missing) do |name, *args, &block|
          return super(name, *args, &block) unless succession.singleton_methods.include? name
          __node.next.value.public_send name, *args, &block
        end
      self; end
    end
  end

end
