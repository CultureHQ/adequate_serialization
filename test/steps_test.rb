# frozen_string_literal: true

class StepsTest < Minitest::Test
  def test_response_mutate
    response = AdequateSerialization::Steps::Response.new(Object.new, nil)
    mutated = response.mutate('foo')

    assert_nil response.current

    assert_kind_of AdequateSerialization::Steps::Response, mutated
    assert_equal 'foo', mutated.current
  end
end
