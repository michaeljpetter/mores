module Mores

  class ImmutableStruct < ::Struct
    %w[
      flyweight
      strict
    ].each { |file| require_relative "immutable_struct/#{file}" }

    undef_method :[]=

    def self.new(*args, flyweight: true, strict: false, &block)
      super(*args, &block).tap do |klass|
        klass.instance_eval do
          members.each { |x| remove_method "#{x}=" }
          include Flyweight if flyweight
          include Strict if strict
        end
      end
    end
  end

end
