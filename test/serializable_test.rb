# frozen_string_literal: true

class SerializableTest < Minitest::Test
  class Foo
    include AdequateSerialization::Serializable

    def foo
      'foo'
    end
  end

  class FooSerializer < AdequateSerialization::Serializer
    attribute :foo
  end

  def test_serializer
    assert_kind_of FooSerializer, Foo.serializer
  end

  def test_as_json
    response =
      AdequateSerialization::Steps.stub(:apply, 'response') do
        Foo.new.as_json
      end

    assert_equal 'response', response
  end
end
