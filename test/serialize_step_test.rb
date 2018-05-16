# frozen_string_literal: true

class SerializeStepTest < Minitest::Test
  include AdequateSerialization::Steps

  def test_serialize_step
    response = Response.new(User.new, AdequateSerialization::Options.null)

    assert_equal User::NAME, SerializeStep.new.apply(response)[:name]
  end
end
