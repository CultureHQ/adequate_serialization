# frozen_string_literal: true

class SerializeStepTest < Minitest::Test
  include AdequateSerialization::Steps

  class Foo
    include AdequateSerialization::Serializable

    def foo
      'foo'
    end
  end

  class FooSerializer < AdequateSerialization::Serializer
    attribute :foo
  end

  def test_serialize_step
    response = Response.new(Foo.new, AdequateSerialization::Options.null)

    assert_equal 'foo', SerializeStep.new.apply(response)[:foo]
  end
end
