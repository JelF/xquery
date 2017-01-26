module XQuery
  # This proxy can be used to access raw wrappers inside classes,
  # inherited from XQuery::Abstract
  # @attr instance [XQuery::Abstract]
  #   Wrapped instance
  class QueryProxy
    # @param instance [XQuery::Abstract] instance to delegate methods
    def initialize(instance)
      self.instance = instance
    end

    private

    attr_accessor :instance
  end
end
