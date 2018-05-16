# frozen_string_literal: true

require 'test_helper'

class AdequateSerializationTest < Minitest::Test
  def test_dump_on_hash
    value = { foo: 'baz' }

    assert_equal value, AdequateSerialization.dump(value)
  end

  def test_dump_on_non_serialized_responsive
    value = Object.new

    assert_equal value, AdequateSerialization.dump(value)
  end

  def test_dump_on_serialized_responsive
    value = Object.new
    def value.serialized
      'baz'
    end

    assert_equal 'baz', AdequateSerialization.dump(value)
  end
end
