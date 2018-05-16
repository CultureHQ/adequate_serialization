# frozen_string_literal: true

class StepsTest < Minitest::Test
  include AdequateSerialization::Steps

  def test_response_mutate
    response = Response.new(Object.new, nil)
    mutated = response.mutate('foo')

    assert_nil response.current

    assert_kind_of Response, mutated
    assert_equal 'foo', mutated.current
  end
end
