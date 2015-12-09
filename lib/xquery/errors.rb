module XQuery
  # raised when superclass of query changed
  class QuerySuperclassChanged < StandardError
    # query on which constraint failed
    attr_reader :result

    # expected superclass of query
    attr_reader :expectation

    # @param result [Object] query on which constraint failed
    # @param expectation [Class] expected superclass
    def initialize(result, expectation)
      @result = result
      @expectation = expectation
      super("Expected #{result.inspect} to be an instance of #{expectation}")
    end
  end
end
