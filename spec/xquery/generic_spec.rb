require 'active_support/core_ext/object/try.rb'

describe XQuery::Generic do
  specify 'it works good!' do
    r = XQuery('9 bottle of juice, please') do |q|
      q.sub('juice', 'beer')
      q[(/\d+/)]
      q.to_i
      q / 3
    end
    expect(r).to eq(3)
  end

  specify 'try stuff' do
    r = XQuery(9) do |q|
      q.try(:-, 9)
      q.nonzero?
      q.try(:-, 9)
    end

    expect(r).to be_nil
  end
end
