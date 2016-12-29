module Mores::ImmutableStruct::Strict
  def initialize(*args)
    unless args.count == members.count
      raise ArgumentError, "wrong number of arguments (#{args.count} for #{members.count})"
    end
    super
  end
end
