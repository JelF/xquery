require 'active_support/core_ext/class/attribute.rb'

require 'xquery/query_proxy'
require 'xquery/errors'

module XQuery
  # abstract superclass, should be inherited, not used
  class Abstract
    class_attribute :query_superclass

    # yields instance inside block. I suggest to name it `q`
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

    # Aliases method to __method and q.method
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

    # same as wrap_method, but hanldes multiply methods
    # @param methods [Array(#to_sym)] names of methods defined
    def self.wrap_methods(*methods)
      methods.each(&method(:wrap_method))
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

    private

    attr_writer :query

    # @private_api
    # updates query by calling method on it and storing the result
    def _update_query(method, *args, &block)
      self.query = query.public_send(method, *args, &block)
      validate!
      self
    end

    # checks constraints
    # @raise XQuery::QuerySuperclassChanged
    def validate!
      return true if query.is_a?(query_superclass)
      fail QuerySuperclassChanged.new(query, query_superclass)
    end

    # @return [XQuery::QueryProxy] object could be used
    #   to access method wrappers unchanged
    def q
      @query_proxy
    end
  end
end
