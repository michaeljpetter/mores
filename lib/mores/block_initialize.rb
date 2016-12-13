module Mores

  module BlockInitialize
    def new(*args, &block)
      case block_given? and block.arity
      when 0
        super(*args, &nil).tap { |x| x.instance_exec &block }
      when 1
        super(*args, &nil).tap &block
      else
        super
      end
    end
  end

end
