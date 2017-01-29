require "forwardable"

require "yield_decorator"

module AWS
  module Lambda
    module_function

    class Functions
      def initialize
        @store = {}
      end

      def register(name, handler)
        handler_proc = YieldDecorator.new(handler).method(:call).to_proc

        @store[name] = handler_proc
        $exports[name] = handler_proc
      end
      alias []= register

      include Enumerable
      extend Forwardable

      def_delegators :@store, :each, :[]
    end
    private_constant :Functions

    def functions
      @@functions ||= Functions.new
    end
  end
end
