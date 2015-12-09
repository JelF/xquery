require 'xquery/abstract'

class Implementation < XQuery::Abstract
  wrap_method :foo
  wrap_method :bar, as: :baz
  wrap_method :change_superclass!

  self.query_superclass = RSpec::Mocks::Double

  def sequence
    foo
    baz
    query
  end

  # make it public
  def q
    super
  end
end

describe XQuery::Abstract do
  subject(:implementation) { Implementation.new(model) }
  let(:result) { double(:result) }

  let(:model) do
    model = double(:first, foo: double(:second, bar: result))
    allow(model).to receive(:change_superclass!).and_return(nil)
    model
  end

  specify 'using class itself' do
    expect(Implementation.new(model).sequence).to eq(result)
  end

  describe '#with' do
    specify 'using defined methods' do
      expect(Implementation.with(model, &:sequence)).to eq(result)
    end

    specify 'using raw methods' do
      r = Implementation.with(model) do |q|
        q.foo
        expect(q).not_to respond_to(:bar)
        q.baz
      end

      expect(r).to eq(result)
    end
  end

  specify 'using q' do
    q = implementation.q
    q.foo.baz
    expect(implementation.query).to eq(result)
  end

  specify '#validation' do
    message = 'Expected nil to be an instance of RSpec::Mocks::Double'

    Implementation.with(model) do |q|
      expect { q.change_superclass! }
        .to raise_error(XQuery::QuerySuperclassChanged, message)
    end
  end
end
