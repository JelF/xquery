require 'active_support/core_ext/class/attribute.rb'

require 'xquery/query_proxy'
require 'xquery/errors'

module XQuery
  # Abstract superclass, should be inherited, not used
  # @attr query
  #   contains current state of wrapped query
  class Abstract
    class_attribute :query_superclass
    self.query_superclass = Object

    attr_reader :query

    # Yields instance inside block. I suggest to name it `q`
    # @param args [Array(Object)]
    #   array of arguments would be passed to `new`
    # @yield [XQuery::Abstract] new intance
    # @return resulting query
    def self.with(*args)
      new(*args).with { |instance| yield(instance) }
    end

    # Defines `method`, `__method` and `q.method`.
    # Both of witch changes query to query.method
    # @param name [#to_sym] name of method on query
    # @option as [#to_sym] name of method defined
    def self.wrap_method(name, as: name)
      define_method(as) { |*args, &block| _update_query(name, *args, &block) }
      alias_on_q(as, true)
    end

    # Aame as wrap_method, but hanldes multiply methods
    # @param methods [Array(#to_sym)] names of methods defined
    def self.wrap_methods(*methods)
      methods.each(&method(:wrap_method))
    end

    # Aliases method to `#__method` and `q.method`
    # @param name [#to_sym] name of method
    # @param return_self [Boolean] should defined method return self or result
    def self.alias_on_q(name, return_self = false)
      alias_method("__#{name}", name)
      private("__#{name}")

      query_proxy.send(:define_method, name) do |*args, &block|
        result = instance.send("__#{name}", *args, &block)
        return_self ? self : result
      end
    end

    # @return [Class] query_proxy (`q`) class
    def self.query_proxy
      @query_proxy ||= Class.new(QueryProxy)
    end

    # inherited classes should also have their query_proxies inherited
    # @api private
    # @param child [Class] class inheriting this
    def self.inherited(child)
      child.instance_variable_set(:@query_proxy, Class.new(query_proxy))
    end

    # @param query [Object] generic query
    def initialize(query)
      self.query = query
      @query_proxy = self.class.query_proxy.new(self)
    end

    # Yields iteself inside block. I suggest to name it `q`
    # @yield [XQuery::Abstract] itself
    # @return [Object] query
    def with
      yield(self)
      query
    end

    # Executes specified method, returns query.
    # Feel free to redefine this method in case it's only public api method
    # in your class
    # @param method [#to_sym] any instance public method name
    # @param args [Array(Object)] method call params
    # @param block [#to_proc] block would be sent to method
    # @return [Object] query
    def execute(method, *args, &block)
      public_send(method, *args, &block)
      query
    end

    # Yields query inside block
    # @yield query
    # @return [XQuery::Abstract] self
    def apply
      self.query = yield(query)
      self
    end

    private

    # Updates query by calling method on it and storing the result
    # @api private
    # @return [XQuery::Abstract] self
    def _update_query(method, *args, &block)
      apply { |x| x.public_send(method, *args, &block) }
    end

    # Added constraints check
    # @raise XQuery::QuerySuperclassChanged
    def query=(x)
      unless x.is_a?(query_superclass)
        raise QuerySuperclassChanged.new(x, query_superclass)
      end

      @query = x
    end

    # @return [XQuery::QueryProxy] object could be used
    #   to access method wrappers unchanged
    def q
      @query_proxy
    end
  end
end
