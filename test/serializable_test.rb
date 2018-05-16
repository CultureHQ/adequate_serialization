# frozen_string_literal: true

class SerializableTest < Minitest::Test
  def test_serializer
    assert_kind_of UserSerializer, User.serializer
  end

  def test_serialized
    response =
      AdequateSerialization::Steps.stub(:apply, 'response') do
        User.new.serialized
      end

    assert_equal 'response', response
  end
end
