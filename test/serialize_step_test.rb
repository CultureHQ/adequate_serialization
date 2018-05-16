# frozen_string_literal: true

class SerializeStepTest < Minitest::Test
  include AdequateSerialization::Steps

  def test_serialize_step
    user = User.new
    response = Response.new(user, AdequateSerialization::Options.null)

    assert_equal user.name, SerializeStep.new.apply(response)[:name]
  end
end
