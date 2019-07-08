# frozen_string_literal: true

require 'test_helper'

class AttributeTest < Minitest::Test
  include AdequateSerialization::Attribute

  class Model
    def initialize(condition = true)
      @condition = condition
    end

    def foo
      'baz'
    end

    def foo?
      @condition
    end
  end

  def test_simple_attribute
    attribute = Simple.new(:foo)
    serialized = {}

    attribute.serialize_to(nil, serialized, Model.new, [])
    assert_equal 'baz', serialized[:foo]
  end

  def test_synthesized_attribute
    attribute = Synthesized.new(:bar) { |model| model.foo * 2 }
    serialized = {}

    attribute.serialize_to(nil, serialized, Model.new, [])
    assert_equal 'bazbaz', serialized[:bar]
  end

  def test_if_condition_name
    attribute = IfCondition.new(Simple.new(:foo), :foo?)

    assert_equal :foo, attribute.name
  end

  def test_if_condition_attribute_when_true
    attribute = IfCondition.new(Simple.new(:foo), :foo?)
    serialized = {}

    attribute.serialize_to(nil, serialized, Model.new(true), [])
    assert_equal 'baz', serialized[:foo]
  end

  def test_if_condition_attribute_when_false
    attribute = IfCondition.new(Simple.new(:foo), :foo?)
    serialized = {}

    attribute.serialize_to(nil, serialized, Model.new(false), [])
    refute serialized.key?(:foo)
  end

  def test_unless_condition_name
    attribute = UnlessCondition.new(Simple.new(:foo), :foo?)

    assert_equal :foo, attribute.name
  end

  def test_unless_condition_attribute_when_true
    attribute = UnlessCondition.new(Simple.new(:foo), :foo?)
    serialized = {}

    attribute.serialize_to(nil, serialized, Model.new(true), [])
    refute serialized.key?(:foo)
  end

  def test_unless_condition_attribute_when_false
    attribute = UnlessCondition.new(Simple.new(:foo), :foo?)
    serialized = {}

    attribute.serialize_to(nil, serialized, Model.new(false), [])
    assert_equal 'baz', serialized[:foo]
  end

  def test_optional_condition_name
    attribute = Optional.new(Simple.new(:foo))

    assert_equal :foo, attribute.name
  end

  def test_optional_attribute_when_included
    attribute = Optional.new(Simple.new(:foo))
    serialized = {}

    attribute.serialize_to(nil, serialized, Model.new, %i[foo])
    assert_equal 'baz', serialized[:foo]
  end

  def test_optional_attribute_when_not_included
    attribute = Optional.new(Simple.new(:foo))
    serialized = {}

    attribute.serialize_to(nil, serialized, Model.new, [])
    refute serialized.key?(:foo)
  end

  def test_from_simple
    attribute = AdequateSerialization::Attribute.from(:foo, {})

    assert_kind_of Simple, attribute
    assert_equal :foo, attribute.name
  end

  def test_from_if
    attribute = AdequateSerialization::Attribute.from(:foo, if: :foo?)

    assert_kind_of IfCondition, attribute
    assert_equal :foo, attribute.attribute.name
  end

  def test_from_unless
    attribute = AdequateSerialization::Attribute.from(:foo, unless: :foo?)

    assert_kind_of UnlessCondition, attribute
    assert_equal :foo, attribute.attribute.name
  end

  def test_from_optional
    attribute = AdequateSerialization::Attribute.from(:foo, optional: true)

    assert_kind_of Optional, attribute
    assert_equal :foo, attribute.attribute.name
  end

  def test_from_synthesized
    attribute =
      AdequateSerialization::Attribute.from(:foo) do |record|
        record.foo * 2
      end

    assert_kind_of Synthesized, attribute
    assert_equal :foo, attribute.name
    assert_equal 'bazbaz', attribute.serialize_to(nil, {}, Model.new, [])
  end
end
