require 'active_support/core_ext/class/attribute.rb'

require 'xquery/query_proxy'
require 'xquery/errors'

module XQuery
  # abstract superclass, should be inherited, not used
  class Abstract
    class_attribute :query_superclass

    # yields instance inside block. I suggest to name it `q`
    # @param query [Object] generic query
    # @param block [#to_proc] block to witch instance would be yielded
    def self.with(query, &block)
      instance = new(query)
      block.call(instance)
      instance.query
    end

    # Defines `method`, `__method` and `q.method`.
    # Both of wich changes query to query.method
    # @param name [#to_sym] name of method on query
    # @param as [#to_sym] name of method defined
    def self.wrap_method(name, as: name)
      define_method(as) { |*args, &block| _update_query(name, *args, &block) }
      alias_method("__#{as}", as)
      private("__#{as}")

      query_proxy.send(:define_method, as) do |*_args, &_block|
        instance.send("__#{as}")
        self
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
