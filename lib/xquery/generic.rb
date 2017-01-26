require 'xquery/abstract'

module XQuery
  # delegates all operations to model
  class Generic < Abstract
    # all missing methods would be delegated to query
    # and processed as wrappers process them
    def method_missing(name, *args, &block)
      super unless respond_to_missing?(name)
      _update_query(name, *args, &block)
    end

    # respond to all public model methods
    def respond_to_missing?(name, *)
      query.respond_to?(name, true)
    end

    private

    # q object refers to self, not proxy
    def q
      self
    end
  end
end
