# frozen_string_literal: true

class StepsTest < Minitest::Test
  def test_apply
    expected = { id: User::ID, name: User::NAME }
    actual = AdequateSerialization::Steps.apply(User.new)

    assert_equal expected, actual
  end

  def test_apply_with_attachments
    expected = { id: User::ID, name: User::NAME, age: 27 }

    ages = { 1 => 27 }
    actual = AdequateSerialization::Steps.apply(User.new, attach: { age: ages })

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
