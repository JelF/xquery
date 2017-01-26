module XQuery
  # raised when superclass of query changed
  # @attr result
  #   query on which constraint failed
  # @attr [Class] expectation
  #   expected superclass of query
  class QuerySuperclassChanged < StandardError
    attr_reader :result
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
