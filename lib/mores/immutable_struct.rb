module Mores

  class ImmutableStruct < ::Struct
    require_relative 'immutable_struct/flyweight'
    require_relative 'immutable_struct/strict'

    DEFAULT_OPTIONS = { flyweight: true }.freeze

    undef_method :[]=

    def self.new(*args, **options, &block)
      options = DEFAULT_OPTIONS.merge options

      super(*args, &block).tap do |klass|
        klass.instance_eval do
          members.each { |x| remove_method "#{x}=" }
          include Flyweight if options[:flyweight]
          include Strict if options[:strict]
        end
      end
    end
  end

end
