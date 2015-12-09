module XQuery
  # This proxy can be used to access raw wrappers inside classes,
  # inherited from XQuery::Abstract
  class QueryProxy
    # @param instance [Xquery::Abstract] instance to delegate methods
    def initialize(instance)
      self.instance = instance
    end

    private

    # instance of Xquery::Abstract
    attr_accessor :instance
  end
end
