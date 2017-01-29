class YieldDecorator
  # @param [#call] a callable object expecting a block
  def initialize(method)
    @method = method
  end

  # Calls the callable object
  # If the last argument passed is callable, convert it to a block.
  def call(*args)
    block = args.pop if args.last.respond_to?(:call)
    @method.call(*args, &block)
  end
end
