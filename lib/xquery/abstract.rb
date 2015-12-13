require 'active_support/core_ext/class/attribute.rb'

require 'xquery/query_proxy'
require 'xquery/errors'

module XQuery
  # Abstract superclass, should be inherited, not used
  class Abstract
    class_attribute :query_superclass

    # Yields instance inside block. I suggest to name it `q`
    # @param args [Array(Object)] array of arguments would be passed to
    # @param block [#to_proc] block to witch instance would be yielded
    def self.with(*args, &block)
      instance = new(*args)
      block.call(instance)
      instance.query
    end

    # Defines `method`, `__method` and `q.method`.
    # Both of wich changes query to query.method
    # @param name [#to_sym] name of method on query
    # @param as [#to_sym] name of method defined
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
    def self.inherited(child)
      child.instance_variable_set(:@query_proxy, Class.new(query_proxy))
    end

    # contains current state of wrapped query
    attr_reader :query

    # @param query [Object] generic query
    def initialize(query)
      self.query = query
      @query_proxy = self.class.query_proxy.new(self)
    end

    # Yields iteself inside block. I suggest to name it `q`
    # @param block [#to_proc] block to whitch instance would be yielded
    # @return [Object] query
    def with(&block)
      block.call(self)
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
    # @param block [#to_proc]
    # @return [XQuery::Abstract] self
    def apply(&block)
      self.query = block.call(query)
      self
    end

    private

    # Private Api!
    # Updates query by calling method on it and storing the result
    # @return [XQuery::Abstract] self
    def _update_query(method, *args, &block)
      apply { |x| x.public_send(method, *args, &block) }
    end

    # Added constraints check
    # @raise XQuery::QuerySuperclassChanged
    def query=(x)
      unless x.is_a?(query_superclass)
        fail QuerySuperclassChanged.new(x, query_superclass)
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
