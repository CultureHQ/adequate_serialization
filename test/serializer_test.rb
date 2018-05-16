# frozen_string_literal: true

class SerializerTest < Minitest::Test
  class Foo
    ATTRIBUTES =
      %i[foo bar if_foo if_bar unless_foo unless_bar opt_foo opt_bar all].freeze

    def initialize(foo: true, bar: true)
      @foo_condition = foo
      @bar_condition = bar
    end

    ATTRIBUTES.each do |attribute|
      define_method(attribute) { attribute.to_s }
    end

    def foo?
      @foo_condition
    end

    def bar?
      @bar_condition
    end
  end

  class FooSerializer < AdequateSerialization::Serializer
    attribute :foo, :bar
    attribute :synth_foo do |foo|
      foo.foo * 2
    end

    attribute :if_foo, :if_bar, if: :foo?
    attribute :unless_foo, :unless_bar, unless: :foo?
    attribute :opt_foo, :opt_bar, optional: true

    attribute :all, if: :foo?, unless: :bar?, optional: true
  end

  def test_attributes
    assert_equal 10, FooSerializer.attributes.size
  end

  def test_attribute
    previous = FooSerializer.attributes

    FooSerializer.attribute(:new)
    assert_equal :new, FooSerializer.attributes.last.name
  ensure
    FooSerializer.instance_variable_set(:@attributes, previous)
  end

  def test_serialize_with_if
    expected = base_expected.merge!(if_foo: 'if_foo', if_bar: 'if_bar')
    actual = FooSerializer.new.serialize(Foo.new(foo: true))

    assert_equal expected, actual
  end

  def test_serialize_with_unless
    expected =
      base_expected.merge!(
        unless_foo: 'unless_foo',
        unless_bar: 'unless_bar'
      )
    actual = FooSerializer.new.serialize(Foo.new(foo: false))

    assert_equal expected, actual
  end

  def test_serialize_includes
    expected = base_expected.merge!(
      if_foo: 'if_foo',
      if_bar: 'if_bar',
      opt_foo: 'opt_foo',
      opt_bar: 'opt_bar'
    )

    opts = AdequateSerialization::Options.from(includes: %i[opt_foo opt_bar])
    actual = FooSerializer.new.serialize(Foo.new(foo: true), opts)

    assert_equal expected, actual
  end

  def test_serialize_all
    opts = AdequateSerialization::Options.from(includes: %i[all])
    actual = FooSerializer.new.serialize(Foo.new(foo: true, bar: false), opts)

    assert_equal 'all', actual[:all]
  end

  private

  def base_expected
    { foo: 'foo', bar: 'bar', synth_foo: 'foofoo' }
  end
end
