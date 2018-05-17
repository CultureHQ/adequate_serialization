# frozen_string_literal: true

class StepsTest < Minitest::Test
  def setup
    Rails.cache.clear
  end

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
    object = Object.new
    response = AdequateSerialization::Steps::Response.new(object, nil)

    mutated = response.mutate('foo')
    assert_equal object, response.object

    assert_kind_of AdequateSerialization::Steps::Response, mutated
    assert_equal 'foo', mutated.object
  end
end
