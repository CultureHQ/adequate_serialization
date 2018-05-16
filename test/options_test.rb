# frozen_string_literal: true

class OptionsTest < Minitest::Test
  include AdequateSerialization::Options

  def test_wraps_includes
    opts = opts_for(includes: :foo)
    includes = opts.includes

    assert_kind_of Array, includes
    assert_equal :foo, includes.first
  end

  def test_keeps_other_options
    opts = opts_for(foo: 'bar')

    assert_equal 'bar', opts.options[:foo]
  end

  def test_from_nothing_passed
    assert_kind_of Opts, AdequateSerialization::Options.from
  end

  def test_from_some_options_passed
    opts = AdequateSerialization::Options.from(includes: :foo)

    assert_kind_of Opts, opts
    assert_equal %i[foo], opts.includes
  end

  def test_null
    opts = AdequateSerialization::Options.null

    assert_kind_of Opts, opts
    assert_empty opts.includes
  end

  private

  def opts_for(options)
    AdequateSerialization::Options::Opts.new(options)
  end
end
