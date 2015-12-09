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
      define_method(as) do |*args, &block|
        self.query = query.public_send(name, *args, &block)
        validate!
        self
      end

      alias_method("__#{as}", as)
      private("__#{as}")
      define_proxy(as)
    end

    # defines method on q
    # @param name [#to_sym] name of binding
    def self.define_proxy(name)
      query_proxy.send(:define_method, name) do |*_args, &_block|
        instance.send("__#{name}")
        self
      end
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

    # checks constraints
    # @raise XQuery::QuerySuperclassChanged
    def validate!
      return true if query.is_a?(query_superclass)
      fail QuerySuperclassChanged.new(query, query_superclass)
    end

    attr_writer :query

    # @return [XQuery::QueryProxy] object could be used
    #   to access method wrappers unchanged
    def q
      @query_proxy
    end
  end
end
