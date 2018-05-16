# frozen_string_literal: true

class StepsTest < Minitest::Test
  def test_apply
    user = User.new

    expected = { id: user.id, name: user.name }
    actual = AdequateSerialization::Steps.apply(user)

    assert_equal expected, actual
  end

  def test_apply_with_attachments
    user = User.new
    expected = { id: user.id, name: user.name, age: 27 }

    ages = { 1 => 27 }
    actual = AdequateSerialization::Steps.apply(user, attach: { age: ages })

    assert_equal expected, actual
  end

  def test_response_mutate
    response = AdequateSerialization::Steps::Response.new(Object.new, nil)
    mutated = response.mutate('foo')

    assert_nil response.current

    assert_kind_of AdequateSerialization::Steps::Response, mutated
    assert_equal 'foo', mutated.current
  end
end
